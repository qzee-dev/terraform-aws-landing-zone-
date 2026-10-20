terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "organizations" {
  source = "../../modules/organizations"

  organization_name = var.organization_name
}
