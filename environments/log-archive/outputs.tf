output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail.bucket
}

output "cloudtrail_bucket_arn" {
  value = aws_s3_bucket.cloudtrail.arn
}

output "cloudtrail_access_logs_bucket_name" {
  value = aws_s3_bucket.access_logs.bucket
}

output "cloudtrail_kms_key_arn" {
  value = aws_kms_key.cloudtrail.arn
}

output "management_trail_arn" {
  value = local.management_trail_arn
}
