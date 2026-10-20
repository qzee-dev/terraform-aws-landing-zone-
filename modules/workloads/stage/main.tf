resource "aws_vpc" "stage" {
  cidr_block           = "10.60.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "stage-vpc"
  }
}

resource "aws_subnet" "app" {
  count                   = 2
  vpc_id                 = aws_vpc.stage.id
  cidr_block             = cidrsubnet(aws_vpc.stage.cidr_block, 8, count.index + 10)
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
}

data "aws_availability_zones" "available" {
  state = "available"
}
