output "securityhub_account_id" {
  value = aws_securityhub_account.this.id
}

output "guardduty_detector_id" {
  value = aws_guardduty_detector.this.id
}

output "config_aggregator_arn" {
  value = aws_config_configuration_aggregator.organization.arn
}
