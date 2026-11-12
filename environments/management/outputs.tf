output "organization_trail_arn" {
  value = aws_cloudtrail.organization.arn
}

output "guardduty_delegated_administrator_account_id" {
  value = aws_guardduty_organization_admin_account.security.admin_account_id
}

output "securityhub_delegated_administrator_account_id" {
  value = aws_securityhub_organization_admin_account.security.admin_account_id
}
