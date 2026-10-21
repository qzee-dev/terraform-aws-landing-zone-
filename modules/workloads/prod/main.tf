data "aws_availability_zones" "available" {
  state = "available"
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

resource "aws_subnet" "app" {
  count                   = 2
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = cidrsubnet(aws_vpc.prod.cidr_block, 8, count.index + 10)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "prod-app-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count                   = 2
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = cidrsubnet(aws_vpc.prod.cidr_block, 8, count.index + 20)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "prod-db-subnet-${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "db" {
  name       = "prod-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id
}

resource "aws_security_group" "db" {
  name        = "prod-db-sg"
  description = "Restricted DB security group"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.50.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "primary" {
  identifier              = "prod-db-primary"
  allocated_storage       = 100
  max_allocated_storage   = 500
  db_name                 = "appdb"
  username                = "dbadmin"
  password                = var.db_password
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = "db.t3.medium"
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  multi_az                = true
  publicly_accessible     = false
  deletion_protection     = true
  backup_retention_period = 7
  storage_encrypted       = true
  skip_final_snapshot     = false
  apply_immediately       = false

  tags = {
    Name        = "prod-db-primary"
    Environment = "Prod"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}
