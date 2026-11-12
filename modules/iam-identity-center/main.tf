data "aws_ssoadmin_instances" "this" {}

resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AWSAdministratorAccess"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  description      = "Full administrator access; assign only to approved, tightly controlled administrators"
  session_duration = "PT1H"
}

resource "aws_ssoadmin_permission_set" "security_audit" {
  name             = "SecurityAudit"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  description      = "Read-only security audit access"
  session_duration = "PT4H"
}

resource "aws_ssoadmin_permission_set" "network_admin" {
  name             = "NetworkAdmin"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  description      = "Network administration access"
  session_duration = "PT4H"
}

resource "aws_ssoadmin_permission_set" "developer" {
  name             = "Developer"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  description      = "Development account power-user access; review and narrow for workload needs"
  session_duration = "PT4H"
}

resource "aws_ssoadmin_permission_set" "read_only" {
  name             = "ReadOnly"
  instance_arn     = data.aws_ssoadmin_instances.this.arns[0]
  description      = "Read-only access for approved account operators"
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "security_audit" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "network_admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.network_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "developer" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "read_only" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
}

resource "aws_ssoadmin_account_assignment" "security_audit" {
  count = var.security_audit_group_id == "" ? 0 : 1

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn
  principal_id       = var.security_audit_group_id
  principal_type     = "GROUP"
  target_id          = var.security_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "network_admin" {
  count = var.network_admin_group_id == "" ? 0 : 1

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.network_admin.arn
  principal_id       = var.network_admin_group_id
  principal_type     = "GROUP"
  target_id          = var.network_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "developer" {
  count = var.developer_group_id == "" ? 0 : 1

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  principal_id       = var.developer_group_id
  principal_type     = "GROUP"
  target_id          = var.development_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "stage_read_only" {
  count = var.stage_readonly_group_id == "" ? 0 : 1

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
  principal_id       = var.stage_readonly_group_id
  principal_type     = "GROUP"
  target_id          = var.staging_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "production_read_only" {
  count = var.prod_readonly_group_id == "" ? 0 : 1

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
  principal_id       = var.prod_readonly_group_id
  principal_type     = "GROUP"
  target_id          = var.production_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "platform_admin" {
  count = var.platform_admin_group_id == "" ? 0 : 1

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = var.platform_admin_group_id
  principal_type     = "GROUP"
  target_id          = var.management_account_id
  target_type        = "AWS_ACCOUNT"
}
