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

module "shared_services" {
  source = "../../modules/network"

  vpcs = {
    shared_services = {
      cidr_block  = var.shared_services_vpc_cidr
      environment = "SharedServices"
    }
  }
}

module "active_directory" {
  source = "../../modules/active-directory"

  vpc_id     = module.shared_services.vpc_ids["shared_services"]
  subnet_ids = module.shared_services.subnet_ids["shared_services"]

  password = var.ad_password
}

resource "aws_security_group" "dns_resolver" {
  name        = "shared-services-dns-resolver"
  description = "Allow DNS queries from the shared-services VPC."
  vpc_id      = module.shared_services.vpc_ids["shared_services"]

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = concat([var.shared_services_vpc_cidr], tolist(var.transit_route_cidrs))
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = concat([var.shared_services_vpc_cidr], tolist(var.transit_route_cidrs))
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = tolist(var.transit_route_cidrs)
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = tolist(var.transit_route_cidrs)
  }
}

module "dns" {
  source = "../../modules/dns"

  private_zone_name   = var.dns_zone_name
  vpc_id              = module.shared_services.vpc_ids["shared_services"]
  security_group_id   = aws_security_group.dns_resolver.id
  inbound_subnet_ids  = module.shared_services.subnet_ids["shared_services"]
  outbound_subnet_ids = module.shared_services.subnet_ids["shared_services"]
}

module "transit_gateway_spoke" {
  source = "../../modules/transit-gateway-spoke"

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.shared_services.vpc_ids["shared_services"]
  subnet_ids         = module.shared_services.subnet_ids["shared_services"]
  route_table_id     = module.shared_services.route_table_ids["shared_services"]
  route_cidrs        = var.transit_route_cidrs
}
