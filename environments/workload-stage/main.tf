terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "stage" {
  source = "../../modules/workloads/stage"

  db_password = var.db_password
}
