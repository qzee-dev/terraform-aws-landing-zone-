resource "aws_securityhub_account" "this" {
  auto_enable_controls = true
}

resource "aws_guardduty_detector" "this" {
  enable = true
}

resource "aws_config_configuration_recorder" "this" {
  name = "config-recorder"

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  role_arn = aws_iam_role.config.arn
}

resource "aws_config_delivery_channel" "this" {
  name = "config-delivery"

  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  snapshot_delivery_properties {
    delivery_frequency = "Six_Hours"
  }
}

resource "aws_iam_role" "config" {
  name = "config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "config" {
  name = "config-role-policy"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.config_bucket.arn,
          "${aws_s3_bucket.config_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "config_bucket" {
  bucket        = "config-log-bucket-${random_string.suffix.result}"
  force_destroy = false

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.config.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "config-log-bucket"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_kms_key" "config" {
  description             = "KMS key for Config"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}
