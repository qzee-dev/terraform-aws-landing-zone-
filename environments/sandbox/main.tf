terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "sandbox" {
  source = "../../modules/workloads/dev"

  db_password = var.db_password
}
