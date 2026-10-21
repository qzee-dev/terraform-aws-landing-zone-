data "aws_ssoadmin_instances" "this" {}

resource "aws_ssoadmin_permission_set" "admin" {
  name         = "AWSAdministratorAccess"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
  description  = "Full admin access for approved administrative roles"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set" "security_admin" {
  name         = "SecurityAdmin"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
  description  = "Security-only administrator access"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_permission_set" "network_admin" {
  name         = "NetworkAdmin"
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
  description  = "Network administration access"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "security_admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
  permission_set_arn = aws_ssoadmin_permission_set.security_admin.arn
}

resource "aws_ssoadmin_managed_policy_attachment" "network_admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.network_admin.arn
}

resource "aws_ssoadmin_account_assignment" "security_admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.security_admin.arn
  principal_id      = var.security_admin_group_id
  principal_type    = "GROUP"
  target_id         = var.security_account_id
  target_type       = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "network_admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.network_admin.arn
  principal_id      = var.network_admin_group_id
  principal_type    = "GROUP"
  target_id         = var.network_account_id
  target_type       = "AWS_ACCOUNT"
}
