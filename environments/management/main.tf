terraform {
  required_version = ">= 1.10.0"
  backend "s3" {}
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]

  assume_role {
    role_arn = var.terraform_role_arn
  }
}

resource "aws_organizations_delegated_administrator" "identity_center" {
  account_id        = var.identity_center_delegated_admin_account_id
  service_principal = "sso.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "config" {
  account_id        = var.security_account_id
  service_principal = "config.amazonaws.com"
}

resource "aws_guardduty_detector" "management" {
  enable = true
}

resource "aws_guardduty_organization_admin_account" "security" {
  admin_account_id = var.security_account_id

  depends_on = [aws_guardduty_detector.management]
}

resource "aws_securityhub_account" "management" {}

resource "aws_securityhub_organization_admin_account" "security" {
  admin_account_id = var.security_account_id

  depends_on = [aws_securityhub_account.management]
}

resource "aws_cloudtrail" "organization" {
  name                          = "organization-trail"
  s3_bucket_name                = var.log_archive_bucket_name
  kms_key_id                    = var.log_archive_kms_key_arn
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
}

module "config_recorder" {
  source = "../../modules/config-recorder"
}

module "iam_identity_center" {
  source = "../../modules/iam-identity-center"

  security_audit_group_id = var.security_audit_group_id
  network_admin_group_id  = var.network_admin_group_id
  developer_group_id      = var.developer_group_id
  stage_readonly_group_id = var.stage_readonly_group_id
  prod_readonly_group_id  = var.prod_readonly_group_id
  platform_admin_group_id = var.platform_admin_group_id
  management_account_id   = var.expected_account_id
  security_account_id     = var.security_account_id
  network_account_id      = var.network_account_id
  development_account_id  = var.development_account_id
  staging_account_id      = var.staging_account_id
  production_account_id   = var.production_account_id
}
