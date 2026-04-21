# DevOps-CI-CD

Це навчальний проєкт, у якому Django-застосунок проходить повний шлях:

- локальний запуск через Docker Compose
- створення AWS-інфраструктури через Terraform
- збірка Docker image
- push image в Amazon ECR
- деплой у Amazon EKS через Helm
- CI/CD через Jenkins + Kaniko + GitOps repo
- автоматична синхронізація через Argo CD

Простіше кажучи: тут зібраний базовий DevOps pipeline для Django.

## Що є в репозиторії

```text
docker/
├── django/                # Django-проєкт і Dockerfile
├── nginx/                 # Nginx конфіг для локального запуску
└── docker-compose.yaml    # Локальний запуск Django + Postgres + Nginx

terraform/
├── backend.tf             # S3 backend для Terraform state
├── ci-cd.tf               # Підключення модулів Jenkins і Argo CD
├── main.tf                # Головний Terraform конфіг
├── outputs.tf             # Корисні outputs
├── variables.tf           # Параметри для CI/CD та Helm-релізів
├── versions.tf            # Піни провайдерів Terraform
└── modules/
    ├── ci-iam/            # IAM role + OIDC provider для Jenkins agent
    ├── jenkins/           # Helm-установка Jenkins як окремий модуль
    ├── argo_cd/           # Helm-установка Argo CD і bootstrap chart
    ├── ecr/               # ECR репозиторій
    ├── eks/               # EKS кластер і node group
    ├── s3-backend/        # Приклад backend-модуля
    └── vpc/               # VPC, subnets, route tables, IGW, NAT

helm/
└── django-chart/          # Helm chart для Django, Postgres і Nginx

Jenkinsfile                # Jenkins pipeline для build/push/update GitOps repo
argocd/application.yaml    # Приклад Argo CD Application manifest
```

Детальніше модулі CI/CD тепер мають таку структуру:

```text
terraform/modules/jenkins/
├── jenkins.tf
├── variables.tf
├── providers.tf
├── values.yaml
└── outputs.tf

terraform/modules/argo_cd/
├── argo_cd.tf
├── variables.tf
├── providers.tf
├── values.yaml
├── outputs.tf
└── charts/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── application.yaml
        └── repository.yaml
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
- Jenkins, встановлений через окремий Terraform-модуль + Helm
- Argo CD, встановлений через окремий Terraform-модуль + Helm
- IAM role для `jenkins-agent` через IRSA
- Argo CD bootstrap chart для `Application` і `Repository` ресурсів

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

Для нового CI/CD ланцюжка додатково потрібен окремий GitOps-репозиторій, у якому лежить Helm chart або `values.yaml`, що відстежується Argo CD.

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
2. Перевірити, що EKS, ECR, Jenkins і Argo CD створилися
3. Додати credentials у Jenkins
4. Запустити Jenkins pipeline
5. Дочекатися, поки Jenkins оновить GitOps-репозиторій
6. Дочекатися, поки Argo CD автоматично синхронізує зміни у кластері

## 1. Підняти інфраструктуру

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init -reconfigure
terraform plan
terraform apply
```

Мінімально в `terraform.tfvars` треба заповнити:

```hcl
jenkins_admin_password = "change-me"
argocd_repo_url        = "https://github.com/ValeriiaSeliverstova/DevOps-CI-CD-gitops.git"
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

## 3. Налаштувати Jenkins

Після `terraform apply` Jenkins встановлюється в namespace `jenkins`.

Щоб увійти локально:

```bash
kubectl -n jenkins port-forward svc/jenkins 8080:8080
```

Логін і пароль беруться з `terraform.tfvars`.

У Jenkins треба додати credentials:

- `gitops-repo-creds` типу `Username with password`
- цей credential використовується для push у GitOps-репозиторій

Потім створіть Pipeline job на основі [`Jenkinsfile`](./Jenkinsfile).

Важливі параметри job:

- `AWS_REGION`
- `ECR_REGISTRY`
- `ECR_REPOSITORY`
- `GITOPS_REPO_URL`
- `GITOPS_VALUES_FILE`
- `GITOPS_BRANCH`

## 4. Що робить Jenkins pipeline

Pipeline запускається в Kubernetes Agent pod із трьома контейнерами:

- `kaniko` для збірки образу
- `git` для checkout/push
- `python` для безпечного оновлення `values.yaml`

Сам pipeline:

1. забирає код застосунку
2. генерує тег образу як `${BUILD_NUMBER}-${GIT_SHA}`
3. збирає Docker image із `docker/django/Dockerfile`
4. пушить image в ECR
5. клонує GitOps-репозиторій
6. оновлює `image.repository` та `image.tag` у `values.yaml`
7. комітить і пушить зміни в `main`

`kaniko` пушить в ECR без статичних AWS ключів: для цього Terraform створює IRSA role й підв’язує її до service account `jenkins-agent`.

## 5. Налаштувати Argo CD

Argo CD встановлюється через Helm у namespace `argocd`.

Для локального входу:

```bash
kubectl -n argocd port-forward svc/argocd-server 8081:80
```

Application створюється локальним Helm chart у модулі `terraform/modules/argo_cd/charts` і стежить за:

- `argocd_repo_url`
- `argocd_repo_path`
- `argocd_target_revision`

Увімкнений `automated` sync із:

- `prune: true`
- `selfHeal: true`
- `CreateNamespace=true`

Приклад окремого маніфесту також є у [`argocd/application.yaml`](./argocd/application.yaml), але основний сценарій тепер іде через модуль `argo_cd`.

## 6. GitOps flow

Після успішного Jenkins build відбувається такий ланцюжок:

1. новий image тег пушиться в ECR
2. Jenkins комітить новий тег у GitOps-репозиторій
3. Argo CD бачить зміну в Git
4. Argo CD автоматично синхронізує Helm chart у кластері

Перевірка:

```bash
kubectl get pods -n django-app
kubectl get svc -n django-app
kubectl get applications -n argocd
```

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
- винести пароль Postgres та інші secret values з Git у External Secrets / AWS Secrets Manager
- додати webhook-тригер Jenkins job від Git-події

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
