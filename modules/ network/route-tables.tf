resource "aws_route_table" "inspection" {
  vpc_id = aws_vpc.inspection.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "local"
  }

  tags = {
    Name        = "inspection-private-rt"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_route_table" "shared_services" {
  vpc_id = aws_vpc.shared_services.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "local"
  }

  tags = {
    Name        = "shared-services-private-rt"
    Environment = "SharedServices"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "local"
  }

  tags = {
    Name        = "prod-private-rt"
    Environment = "Prod"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_route_table" "stage" {
  vpc_id = aws_vpc.stage.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "local"
  }

  tags = {
    Name        = "stage-private-rt"
    Environment = "Stage"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "local"
  }

  tags = {
    Name        = "dev-private-rt"
    Environment = "Dev"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_main_route_table_association" "inspection" {
  vpc_id         = aws_vpc.inspection.id
  route_table_id = aws_route_table.inspection.id
}

resource "aws_main_route_table_association" "shared_services" {
  vpc_id         = aws_vpc.shared_services.id
  route_table_id = aws_route_table.shared_services.id
}

resource "aws_main_route_table_association" "prod" {
  vpc_id         = aws_vpc.prod.id
  route_table_id = aws_route_table.prod.id
}

resource "aws_main_route_table_association" "stage" {
  vpc_id         = aws_vpc.stage.id
  route_table_id = aws_route_table.stage.id
}

resource "aws_main_route_table_association" "dev" {
  vpc_id         = aws_vpc.dev.id
  route_table_id = aws_route_table.dev.id
}
