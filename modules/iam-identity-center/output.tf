output "admin_permission_set_arn" {
  value = aws_ssoadmin_permission_set.admin.arn
}

output "security_audit_permission_set_arn" {
  value = aws_ssoadmin_permission_set.security_audit.arn
}

output "network_admin_permission_set_arn" {
  value = aws_ssoadmin_permission_set.network_admin.arn
}
