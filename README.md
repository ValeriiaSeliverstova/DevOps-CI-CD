# DevOps-CI-

Цей проєкт створює базову AWS інфраструктуру за допомогою Terraform.

Інфраструктура включає:

S3 bucket для збереження Terraform state
DynamoDB таблицю для блокування state
VPC з публічними та приватними підмережами
Internet Gateway та NAT Gateway
Route Tables для маршрутизації
ECR репозиторій для Docker образів

Структура проєкту

lesson-5/
│
├── main.tf # Підключення модулів
├── variables.tf # Змінні
├── outputs.tf # Outputs
│
├── modules/
│ ├── s3-backend/ # S3 + DynamoDB для backend
│ ├── vpc/ # Мережева інфраструктура
│ └── ecr/ # ECR репозиторій
│
└── README.md

Використані сервіси AWS
S3 (для Terraform state)
DynamoDB (для блокування state)
VPC (мережа)
Subnets (public/private)
Internet Gateway
NAT Gateway
ECR (контейнерний реєстр)

Команди для запуску
Ініціалізація Terraform
terraform init
Перегляд плану
terraform plan
Створення інфраструктури
terraform apply
Видалення інфраструктури
terraform destroy
