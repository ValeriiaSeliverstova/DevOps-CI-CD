# RDS module

Це універсальний модуль для бази даних.

Він уміє створювати:

- звичайну `RDS instance`
- або `Aurora cluster`

Все перемикається однією змінною:

```hcl
use_aurora = true
```

## Що створює модуль

У будь-якому режимі модуль створює:

- `DB Subnet Group`
- `Security Group`
- `Parameter Group`

Далі:

- якщо `use_aurora = false`, створюється `aws_db_instance`
- якщо `use_aurora = true`, створюються:
  - `aws_rds_cluster`
  - окремий `writer`
  - окремі `reader` replicas

## Приклад для звичайного PostgreSQL RDS

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = false
  engine     = "postgres"
  engine_version             = "14.22"
  parameter_group_family_rds = "postgres14"

  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "myapp"
  username                = "postgres"
  password                = "admin123AWS23"
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = false
  vpc_id                  = module.vpc.vpc_id
  multi_az                = false
  backup_retention_period = "7"

  parameters = {
    max_connections = "200"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## Приклад для Aurora PostgreSQL

```hcl
module "rds" {
  source = "./modules/rds"

  name                          = "myapp-db"
  use_aurora                    = true
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  instance_class          = "db.t3.medium"
  db_name                 = "myapp"
  username                = "postgres"
  password                = "admin123AWS23"
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = true
  vpc_id                  = module.vpc.vpc_id
  backup_retention_period = "7"
  aurora_replica_count    = 1

  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## Як переключити RDS і Aurora

### Звичайний RDS

```hcl
use_aurora = false
engine     = "postgres"
```

або

```hcl
use_aurora = false
engine     = "mysql"
```

### Aurora

```hcl
use_aurora = true
engine_cluster = "aurora-postgresql"
engine_version_cluster = "15.3"
parameter_group_family_aurora = "aurora-postgresql15"
```

або

```hcl
use_aurora = true
engine_cluster = "aurora-mysql"
```

## Основні змінні

- `name` — базова назва ресурсів
- `use_aurora` — чи створювати Aurora замість звичайного RDS
- `aurora_replica_count` — скільки reader replicas створити в Aurora
- `engine` — тип звичайної RDS: `postgres` або `mysql`
- `engine_cluster` — тип Aurora: `aurora-postgresql` або `aurora-mysql`
- `engine_version` — версія звичайної RDS
- `engine_version_cluster` — версія Aurora
- `instance_class` — клас інстансу
- `allocated_storage` — розмір диска для звичайного RDS
- `db_name` — назва початкової бази
- `username` — master username
- `password` — master password
- `subnet_private_ids` — private subnets для DB subnet group
- `subnet_public_ids` — public subnets, якщо БД має бути public
- `publicly_accessible` — чи буде публічний endpoint
- `vpc_id` — VPC, у якій створюється БД
- `multi_az` — Multi-AZ для звичайного RDS
- `backup_retention_period` — скільки днів тримати backup
- `parameter_group_family_rds` — family для звичайного RDS, якщо хочеш задати явно
- `parameter_group_family_aurora` — family для Aurora, якщо хочеш задати явно
- `parameters` — map з параметрами для parameter group

## Як міняти налаштування

### Змінити тип БД

Просто змінюєш:

```hcl
engine = "postgres"
```

або

```hcl
engine = "mysql"
```

або для Aurora:

```hcl
engine_cluster = "aurora-postgresql"
```

### Змінити версію БД

```hcl
engine_version = "17.2"
```

або для Aurora:

```hcl
engine_version_cluster = "15.3"
```

### Змінити клас інстансу

```hcl
instance_class = "db.t3.medium"
```

### Додати свої DB parameters

```hcl
parameters = {
  max_connections            = "200"
  log_min_duration_statement = "500"
}
```

Тобто не треба міняти код модуля. Просто передаєш нові значення через змінні.
