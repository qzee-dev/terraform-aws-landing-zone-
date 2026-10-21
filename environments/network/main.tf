terraform {
  backend "s3" {}
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]

  assume_role {
    role_arn = var.terraform_role_arn
  }
}

module "network" {
  source = "../../modules/network"

  vpcs = {
    inspection = {
      cidr_block  = "10.30.0.0/16"
      environment = "Core"
    }
  }
}

module "transit_gateway" {
  source = "../../modules/transit-gateway"

  inspection_vpc_id     = module.network.vpc_ids["inspection"]
  inspection_subnet_ids = module.network.subnet_ids["inspection"]
  spoke_account_ids     = var.transit_gateway_spoke_account_ids
}
