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

module "prod" {
  source = "../../modules/workloads/prod"

  db_password = var.db_password
}

module "transit_gateway_spoke" {
  source = "../../modules/transit-gateway-spoke"

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.prod.vpc_id
  subnet_ids         = module.prod.app_subnet_ids
  route_table_id     = module.prod.route_table_id
  route_cidrs        = var.transit_route_cidrs
}
