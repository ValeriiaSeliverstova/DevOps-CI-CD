terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-goit-valeriia-seliverstova"
    key            = "terraform/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
