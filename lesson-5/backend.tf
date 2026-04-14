# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-lesson-5-valeriia-seliverstova"
#     key            = "lesson-5/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
