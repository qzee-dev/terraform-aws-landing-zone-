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

module "iam_identity_center" {
  source = "../../modules/iam-identity-center"

  security_admin_group_id = var.security_admin_group_id
  network_admin_group_id  = var.network_admin_group_id
  security_account_id     = var.security_account_id
  network_account_id      = var.network_account_id
}
