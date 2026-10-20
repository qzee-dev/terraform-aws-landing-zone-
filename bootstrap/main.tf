terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
    "BACKUP_POLICY"
  ]
}

resource "aws_organizations_organizational_unit" "security" {
  name      = var.ou_security_name
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = var.ou_infrastructure_name
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads_prod" {
  name      = var.ou_workloads_prod_name
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads_nonprod" {
  name      = var.ou_workloads_nonprod_name
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = var.ou_sandbox_name
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_account" "log_archive" {
  name      = "log-archive"
  email     = var.log_archive_account_email
  parent_id = aws_organizations_organizational_unit.security.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_organizations_account" "security_tooling" {
  name      = "security-tooling"
  email     = var.security_tooling_account_email
  parent_id = aws_organizations_organizational_unit.security.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_organizations_account" "network" {
  name      = "network"
  email     = var.network_account_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_organizations_account" "shared_system" {
  name      = "shared-system"
  email     = var.shared_system_account_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_organizations_account" "production" {
  name      = "production"
  email     = var.production_account_email
  parent_id = aws_organizations_organizational_unit.workloads_prod.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_organizations_account" "staging" {
  name      = "staging"
  email     = var.staging_account_email
  parent_id = aws_organizations_organizational_unit.workloads_nonprod.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_organizations_account" "development" {
  name      = "development"
  email     = var.development_account_email
  parent_id = aws_organizations_organizational_unit.workloads_nonprod.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_organizations_account" "sandbox" {
  name      = "sandbox"
  email     = var.sandbox_account_email
  parent_id = aws_organizations_organizational_unit.sandbox.id

  lifecycle {
    ignore_changes = [email]
  }
}

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
  force_destroy = false

  tags = {
    Name        = "tf-state"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "state" {
  description             = "Terraform state KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootUser"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${aws_organizations_organization.this.master_account_id}:root"
        }
        Action = ["kms:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-locks"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}
