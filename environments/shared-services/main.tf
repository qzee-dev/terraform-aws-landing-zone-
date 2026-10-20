terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "shared_services" {
  source = "../../modules/network"

  environment = var.environment
  project_name = var.project_name
}
