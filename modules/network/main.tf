data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  for_each = var.vpcs

  cidr_block           = each.value.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${each.key}-vpc"
    Environment = each.value.environment
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

locals {
  subnet_placements = {
    for placement in setproduct(keys(var.vpcs), range(2)) :
    "${placement[0]}-${placement[1]}" => {
      vpc_name = placement[0]
      index    = placement[1]
    }
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnet_placements

  vpc_id                  = aws_vpc.this[each.value.vpc_name].id
  cidr_block              = cidrsubnet(aws_vpc.this[each.value.vpc_name].cidr_block, 8, each.value.index + 10)
  availability_zone       = data.aws_availability_zones.available.names[each.value.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${each.value.vpc_name}-private-${each.value.index + 1}"
    Environment = var.vpcs[each.value.vpc_name].environment
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}
