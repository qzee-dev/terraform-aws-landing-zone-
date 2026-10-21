data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "dev" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${lower(var.environment)}-vpc"
    Environment = var.environment
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_subnet" "app" {
  count                   = 2
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = cidrsubnet(aws_vpc.dev.cidr_block, 8, count.index + 10)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${lower(var.environment)}-app-subnet-${count.index + 1}"
    Environment = var.environment
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}
