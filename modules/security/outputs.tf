output "securityhub_account_id" {
  value = aws_securityhub_account.this.id
}

output "guardduty_detector_id" {
  value = aws_guardduty_detector.this.id
}

output "config_bucket_name" {
  value = aws_s3_bucket.config_bucket.bucket
}
