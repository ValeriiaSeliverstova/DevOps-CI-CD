# DevOps-CI-CD

Це навчальний проєкт, у якому Django-застосунок проходить повний шлях:

- локальний запуск через Docker Compose
- створення AWS-інфраструктури через Terraform
- збірка Docker image
- push image в Amazon ECR
- деплой у Amazon EKS через Helm

Простіше кажучи: тут зібраний базовий DevOps pipeline для Django.

## Що є в репозиторії

```text
docker/
├── django/                # Django-проєкт і Dockerfile
├── nginx/                 # Nginx конфіг для локального запуску
└── docker-compose.yaml    # Локальний запуск Django + Postgres + Nginx

terraform/
├── backend.tf             # S3 backend для Terraform state
├── main.tf                # Головний Terraform конфіг
├── outputs.tf             # Корисні outputs
└── modules/
    ├── ecr/               # ECR репозиторій
    ├── eks/               # EKS кластер і node group
    ├── s3-backend/        # Приклад backend-модуля
    └── vpc/               # VPC, subnets, route tables, IGW, NAT

helm/
└── django-chart/          # Helm chart для Django, Postgres і Nginx
```

## Що створює Terraform

Після `terraform apply` у AWS з'являються:

- `goit-vpc`
- public і private subnets
- Internet Gateway
- NAT Gateway
- route tables
- ECR репозиторій `goit-ecr`
- EKS кластер `goit-eks`
- node group для EKS

## Що потрібно перед стартом

Локально мають бути встановлені:

- `aws`
- `terraform`
- `docker`
- `kubectl`
- `helm`

Також мають бути налаштовані AWS credentials з доступом до:

- VPC
- IAM
- ECR
- EKS
- S3
- DynamoDB

## Секрети і локальні файли

Реальні секрети не варто зберігати в git.

У цьому репозиторії:

- локальний `.env` не комітиться
- `DJANGO_SECRET_KEY` читається зі змінної середовища
- пароль для Postgres у Helm передається через окремий файл `values.secret.yaml`

### Локальний `.env`

Для Docker Compose використовується локальний `.env`, створений на основі шаблону:

```bash
cp docker/.env.example docker/.env
```

Після цього в `docker/.env` мають бути задані потрібні значення, наприклад:

```env
POSTGRES_HOST=db
POSTGRES_USER=your_user
POSTGRES_DB=your_db
POSTGRES_PASSWORD=your_password
DJANGO_SECRET_KEY=change-me
```

### Secret values для Helm

Для Kubernetes окремо використовується файл із секретами:

```bash
cp helm/django-chart/values.secret.example.yaml helm/django-chart/values.secret.yaml
```

У ньому має бути заданий пароль для Postgres:

```yaml
secret:
  POSTGRES_PASSWORD: "your-strong-password"
```

## Terraform backend

Terraform state зберігається в S3, а не локально.

Поточний backend:

- bucket: `terraform-state-bucket-goit-valeriia-seliverstova`
- table: `terraform-locks`
- region: `us-west-2`
- key: `terraform/terraform.tfstate`

Важливі моменти:

- bucket і DynamoDB table мають існувати до `terraform init`
- якщо backend змінювався, зазвичай потрібен `terraform init -reconfigure`

## Локальний запуск

Для локальної перевірки застосунку використовується:

```bash
cd docker
docker compose up --build
```

Це підніме:

- Django
- Postgres
- Nginx

Цей сценарій не пов'язаний напряму з Terraform або EKS. Це просто локальний стенд.

## Повний запуск у AWS

Типовий порядок роботи виглядає так:

1. Підняти інфраструктуру через Terraform
2. Перевірити, що EKS і ECR створилися
3. Зібрати Docker image
4. Запушити image в ECR
5. Підключитися до EKS
6. Задеплоїти застосунок через Helm

## 1. Підняти інфраструктуру

```bash
cd terraform
terraform init -reconfigure
terraform plan
terraform apply
```

Після створення інфраструктури зазвичай переглядають outputs:

```bash
terraform output
terraform state list
```

Окремо можна подивитися й AWS ресурси:

```bash
aws ecr describe-repositories --region us-west-2
aws eks list-clusters --region us-west-2
```

## 2. Підключитися до EKS

```bash
aws eks update-kubeconfig --region us-west-2 --name goit-eks
kubectl get nodes
```

## 3. Зібрати Docker image

Образ доцільно збирати під `linux/amd64`, щоб він коректно запускався на EKS-нoдах:

```bash
docker buildx build --platform linux/amd64 -t django-app ./docker/django --load
docker image ls
```

## 4. Запушити image в ECR

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 143536904714.dkr.ecr.us-west-2.amazonaws.com
docker tag django-app:latest 143536904714.dkr.ecr.us-west-2.amazonaws.com/goit-ecr:latest
docker push 143536904714.dkr.ecr.us-west-2.amazonaws.com/goit-ecr:latest
aws ecr describe-images --repository-name goit-ecr --region us-west-2
```

## 5. Задеплоїти через Helm

У chart зараз використовується така схема:

- Django працює за внутрішнім `ClusterIP` service
- Nginx публікується назовні через `LoadBalancer`
- Postgres запускається всередині кластера як окремий pod

Перший деплой:

```bash
helm install django-app ./helm/django-chart -f helm/django-chart/values.secret.yaml
```

Оновлення:

```bash
helm upgrade --install django-app ./helm/django-chart -f helm/django-chart/values.secret.yaml
```

Перевірка:

```bash
kubectl get pods
kubectl get svc
kubectl get pvc
```

Після появи `EXTERNAL-IP` у сервісі `django-app-nginx` застосунок стає доступним у браузері.

## Що важливо знати про поточний Helm chart

Зараз chart піднімає:

- Django
- Postgres
- Nginx
- ConfigMap
- Secret
- Service

У поточній конфігурації:

- `postgres.persistence.enabled: false`

Тобто для навчального запуску база даних працює без постійного диска. Якщо pod буде видалений, дані можуть зникнути.

Для більш реального середовища зазвичай розглядають такі кроки:

- увімкнути persistence
- перевірити `StorageClass`
- винести секрети в безпечніше сховище

Ще одна практична деталь: кластер на `t3.micro` дуже маленький. Якщо частина pod-ів зависає в `Pending`, це часто не помилка chart, а нестача місця на нодах.

## Корисні команди

Terraform:

```bash
terraform output
terraform state list
```

AWS:

```bash
aws ecr describe-repositories --region us-west-2
aws ecr describe-images --repository-name goit-ecr --region us-west-2
aws eks list-clusters --region us-west-2
```

Kubernetes:

```bash
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get deployments
kubectl get pvc
```

## Як усе прибрати

Завершення роботи із застосунком у кластері зазвичай починається з видалення Helm release:

```bash
helm uninstall django-app
```

Після цього зазвичай перевіряють, чи не залишилися сервіси або PVC:

```bash
kubectl get pods
kubectl get svc
kubectl get pvc
```

Якщо частина ресурсів не була прибрана автоматично, інколи використовуються окремі команди, наприклад:

```bash
kubectl delete svc django-app-nginx
kubectl delete pvc django-app-postgres
```

Після завершення роботи з Kubernetes-ресурсами прибирається AWS-інфраструктура:

```bash
cd terraform
terraform destroy
```

## Поточні назви ресурсів

- VPC: `goit-vpc`
- ECR: `goit-ecr`
- EKS: `goit-eks`
- S3 backend bucket: `terraform-state-bucket-goit-valeriia-seliverstova`
- DynamoDB lock table: `terraform-locks`
