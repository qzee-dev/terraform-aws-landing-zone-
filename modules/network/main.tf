resource "aws_vpc" "inspection" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "inspection-vpc"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_vpc" "shared_services" {
  cidr_block           = "10.40.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "shared-services-vpc"
    Environment = "SharedServices"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_vpc" "prod" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "prod-vpc"
    Environment = "Prod"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_vpc" "stage" {
  cidr_block           = "10.60.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "stage-vpc"
    Environment = "Stage"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_vpc" "dev" {
  cidr_block           = "10.70.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "dev-vpc"
    Environment = "Dev"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}
