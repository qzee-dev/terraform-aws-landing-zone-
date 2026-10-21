terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../../modules/network"

  environment  = var.environment
  project_name = var.project_name
}

module "transit_gateway" {
  source = "../../modules/transit-gateway"

  prod_vpc_id            = module.network.prod_vpc_id
  stage_vpc_id           = module.network.stage_vpc_id
  dev_vpc_id             = module.network.dev_vpc_id
  inspection_vpc_id      = module.network.inspection_vpc_id
  shared_services_vpc_id = module.network.shared_services_vpc_id

  prod_subnet_ids            = var.prod_subnet_ids
  stage_subnet_ids           = var.stage_subnet_ids
  dev_subnet_ids             = var.dev_subnet_ids
  inspection_subnet_ids      = var.inspection_subnet_ids
  shared_services_subnet_ids = var.shared_services_subnet_ids

  onprem_cidrs = var.onprem_cidrs
}
