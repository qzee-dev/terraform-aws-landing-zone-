terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "prod" {
  source = "../../modules/workloads/prod"

  db_password = var.db_password
}
