terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../../modules/network"

  environment = var.environment
  project_name = var.project_name
}
