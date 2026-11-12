terraform {
  backend "s3" {}

  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.expected_management_account_id]
}

resource "aws_ram_sharing_with_organization" "this" {
  depends_on = [aws_organizations_organization.this]
}

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
  ]
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

resource "aws_organizations_policy" "baseline" {
  name        = "landing-zone-baseline"
  description = "Prevents member accounts from leaving the organization and prevents root access keys."
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/../policies/baseline-scp.json")
}

resource "aws_organizations_policy_attachment" "baseline" {
  for_each = {
    security          = aws_organizations_organizational_unit.security.id
    infrastructure    = aws_organizations_organizational_unit.infrastructure.id
    workloads_prod    = aws_organizations_organizational_unit.workloads_prod.id
    workloads_nonprod = aws_organizations_organizational_unit.workloads_nonprod.id
    sandbox           = aws_organizations_organizational_unit.sandbox.id
  }

  policy_id = aws_organizations_policy.baseline.id
  target_id = each.value
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
  bucket        = var.state_bucket_name
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

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

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
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

  lifecycle {
    prevent_destroy = true
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootUser"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${aws_organizations_organization.this.master_account_id}:root"
        }
        Action   = ["kms:*"]
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

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "terraform-locks"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

locals {
  environment_states = toset([
    "management",
    "security",
    "log-archive",
    "network",
    "shared-services",
    "workload-dev",
    "workload-stage",
    "workload-prod",
    "sandbox",
  ])
}

resource "aws_s3_bucket" "environment_state" {
  for_each = local.environment_states

  bucket        = "${var.environment_state_bucket_prefix}-${var.expected_management_account_id}-${each.key}"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${each.key}-terraform-state"
    Environment = each.key
    Automation  = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "environment_state" {
  for_each = aws_s3_bucket.environment_state

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "environment_state" {
  for_each = aws_s3_bucket.environment_state

  bucket = each.value.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "environment_state" {
  for_each = aws_s3_bucket.environment_state

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "environment_state" {
  for_each = local.environment_states

  description             = "Terraform state encryption key for ${each.key}"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  lifecycle {
    prevent_destroy = true
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableAccountIAMPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.expected_management_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "environment_state" {
  for_each = aws_s3_bucket.environment_state

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.environment_state[each.key].arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "environment_state" {
  for_each = aws_s3_bucket.environment_state

  bucket = each.value.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          each.value.arn,
          "${each.value.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyStateListingOutsideDedicatedRole"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = each.value.arn
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = [
              aws_iam_role.environment_state_access[each.key].arn,
              "arn:aws:iam::${var.expected_management_account_id}:root",
            ]
          }
        }
      },
      {
        Sid       = "DenyStateObjectsOutsideDedicatedRole"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "${each.value.arn}/*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = [
              aws_iam_role.environment_state_access[each.key].arn,
              "arn:aws:iam::${var.expected_management_account_id}:root",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "environment_state_access" {
  for_each = local.environment_states

  name = "TerraformStateAccess-${replace(each.key, "-", "")}"

  lifecycle {
    prevent_destroy = true
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.state_backend_trusted_principal_arns[each.key]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = each.key
    Automation  = "Terraform"
  }
}

resource "aws_iam_role_policy" "environment_state_access" {
  for_each = local.environment_states

  name = "TerraformStateAccess"
  role = aws_iam_role.environment_state_access[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListOnlyThisState"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.environment_state[each.key].arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${each.key}/terraform.tfstate",
              "${each.key}/terraform.tfstate.tflock",
            ]
          }
        }
      },
      {
        Sid    = "ReadWriteOnlyThisState"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = "${aws_s3_bucket.environment_state[each.key].arn}/${each.key}/terraform.tfstate"
      },
      {
        Sid    = "ManageOnlyThisStateLock"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.environment_state[each.key].arn}/${each.key}/terraform.tfstate.tflock"
      },
      {
        Sid    = "UseOnlyThisStateKey"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
        ]
        Resource = aws_kms_key.environment_state[each.key].arn
      }
    ]
  })
}
