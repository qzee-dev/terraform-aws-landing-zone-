variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "expected_account_id" {
  description = "AWS account ID expected to run this environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Use the actual 12-digit security account ID."
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

variable "management_account_id" {
  description = "AWS Organizations management account ID trusted by the security audit role."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "Use the actual 12-digit management account ID from bootstrap."
  }
}

variable "organization_root_id" {
  description = "Organizations root ID output by bootstrap; the Security Hub policy is associated with this root."
  type        = string

  validation {
    condition     = can(regex("^r-[a-z0-9]+$", var.organization_root_id))
    error_message = "Use the actual Organizations root ID from bootstrap."
  }
}

variable "security_alert_email" {
  description = "Optional email recipient for HIGH/CRITICAL GuardDuty and Security Hub findings; confirm the SNS subscription."
  type        = string
  default     = ""

  validation {
    condition     = var.security_alert_email == "" || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.security_alert_email))
    error_message = "Use an empty string to disable email alerts or provide a valid email address."
  }
}
