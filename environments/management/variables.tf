variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "log_archive_bucket_name" {
  description = "CloudTrail destination bucket created by the log-archive environment."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.log_archive_bucket_name))
    error_message = "Use the actual globally unique S3 bucket name from the log-archive environment."
  }
}

variable "log_archive_kms_key_arn" {
  description = "KMS key ARN created with the central CloudTrail bucket."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.log_archive_kms_key_arn))
    error_message = "Use the actual KMS key ARN output by the log-archive environment."
  }
}

variable "expected_account_id" {
  description = "AWS account ID expected to run this environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Use the actual 12-digit management account ID."
  }
}

variable "terraform_role_arn" {
  description = "Role assumed to manage this AWS account."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.terraform_role_arn))
    error_message = "Use the actual IAM role ARN for this environment."
  }
}

variable "identity_center_delegated_admin_account_id" {
  description = "Member account hosting the AD directory used by IAM Identity Center; normally the shared-services account in this scaffold."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.identity_center_delegated_admin_account_id))
    error_message = "Use the actual 12-digit shared-services or dedicated identity account ID."
  }
}

variable "security_audit_group_id" {
  description = "IAM Identity Center group ID for security auditors."
  type        = string

  validation {
    condition     = var.security_audit_group_id == "" || (!strcontains(var.security_audit_group_id, "<") && !strcontains(var.security_audit_group_id, ">"))
    error_message = "Use an actual Identity Center security auditor group ID or leave empty until AD groups are synchronized."
  }
}

variable "network_admin_group_id" {
  description = "IAM Identity Center group ID for network administrators."
  type        = string

  validation {
    condition     = var.network_admin_group_id == "" || (!strcontains(var.network_admin_group_id, "<") && !strcontains(var.network_admin_group_id, ">"))
    error_message = "Use an actual Identity Center network group ID or leave empty until AD groups are synchronized."
  }
}

variable "developer_group_id" {
  description = "IAM Identity Center group ID for developers; assigned only to development."
  type        = string

  validation {
    condition     = var.developer_group_id == "" || (!strcontains(var.developer_group_id, "<") && !strcontains(var.developer_group_id, ">"))
    error_message = "Use an actual Identity Center developer group ID or leave empty until AD groups are synchronized."
  }
}

variable "stage_readonly_group_id" {
  description = "IAM Identity Center group ID for staging read-only access."
  type        = string

  validation {
    condition     = var.stage_readonly_group_id == "" || (!strcontains(var.stage_readonly_group_id, "<") && !strcontains(var.stage_readonly_group_id, ">"))
    error_message = "Use an actual Identity Center staging read-only group ID or leave empty until AD groups are synchronized."
  }
}

variable "prod_readonly_group_id" {
  description = "IAM Identity Center group ID for production read-only access."
  type        = string

  validation {
    condition     = var.prod_readonly_group_id == "" || (!strcontains(var.prod_readonly_group_id, "<") && !strcontains(var.prod_readonly_group_id, ">"))
    error_message = "Use an actual Identity Center production read-only group ID or leave empty until AD groups are synchronized."
  }
}

variable "platform_admin_group_id" {
  description = "Optional group ID for full administrator access to management; leave empty unless explicitly approved."
  type        = string
  default     = ""

  validation {
    condition     = var.platform_admin_group_id == "" || !strcontains(var.platform_admin_group_id, "<")
    error_message = "Use an actual Identity Center group ID or leave this value empty."
  }
}

variable "security_account_id" {
  description = "Security tooling account ID output by bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.security_account_id))
    error_message = "Use the actual 12-digit security account ID from bootstrap."
  }
}

variable "development_account_id" {
  description = "Development workload account ID output by bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.development_account_id))
    error_message = "Use the actual 12-digit development account ID from bootstrap."
  }
}

variable "staging_account_id" {
  description = "Staging workload account ID output by bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.staging_account_id))
    error_message = "Use the actual 12-digit staging account ID from bootstrap."
  }
}

variable "production_account_id" {
  description = "Production workload account ID output by bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.production_account_id))
    error_message = "Use the actual 12-digit production account ID from bootstrap."
  }
}

variable "network_account_id" {
  description = "Network account ID output by bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.network_account_id))
    error_message = "Use the actual 12-digit network account ID from bootstrap."
  }
}
