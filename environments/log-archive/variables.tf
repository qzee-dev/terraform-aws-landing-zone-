variable "aws_region" {
  description = "Home Region for the organization trail and log bucket."
  type        = string
  default     = "us-east-1"
}

variable "expected_account_id" {
  description = "Log Archive account ID from bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Use the actual 12-digit Log Archive account ID."
  }
}

variable "terraform_role_arn" {
  description = "Role assumed to manage the Log Archive account."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.terraform_role_arn))
    error_message = "Use the actual Log Archive Terraform role ARN."
  }
}

variable "management_account_id" {
  description = "Organizations management account ID from bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "Use the actual 12-digit management account ID."
  }
}

variable "organization_id" {
  description = "AWS Organizations ID from bootstrap."
  type        = string

  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Use the actual AWS Organizations ID from bootstrap."
  }
}

variable "log_bucket_prefix" {
  description = "Unique lowercase prefix for the central CloudTrail bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,24}[a-z0-9]$", var.log_bucket_prefix))
    error_message = "Use a 3-26 character lowercase prefix containing letters, numbers, and hyphens."
  }
}

variable "cloudtrail_log_retention_days" {
  description = "Approved CloudTrail and S3 access-log retention in days. Zero disables expiration."
  type        = number
  default     = 0

  validation {
    condition     = var.cloudtrail_log_retention_days == 0 || (var.cloudtrail_log_retention_days >= 90 && floor(var.cloudtrail_log_retention_days) == var.cloudtrail_log_retention_days)
    error_message = "Use 0 for no expiration or an integer retention period of at least 90 days approved by legal and audit owners."
  }
}
