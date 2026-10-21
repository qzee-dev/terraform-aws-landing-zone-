terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

module "shared_services" {
  source = "../../modules/network"

  environment  = var.environment
  project_name = var.project_name
}

module "active_directory" {
  source = "../../modules/active-directory"

  vpc_id     = module.shared_services.shared_services_vpc_id
  subnet_ids = var.shared_services_subnet_ids

  password = var.ad_password
}

module "dns" {
  source = "../../modules/dns"

  vpc_id              = module.shared_services.shared_services_vpc_id
  security_group_id   = var.dns_security_group_id
  inbound_subnet_ids  = var.dns_inbound_subnet_ids
  outbound_subnet_ids = var.dns_outbound_subnet_ids
}
