variable "aws_region" {
  description = "Primary AWS region."
  type        = string
  default     = "us-east-1"
}

variable "expected_management_account_id" {
  description = "AWS account ID expected to run the bootstrap stack."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_management_account_id))
    error_message = "Use the actual 12-digit AWS management account ID."
  }
}

variable "ou_security_name" {
  type    = string
  default = "Security-OU"
}

variable "ou_infrastructure_name" {
  type    = string
  default = "Infrastructure-OU"
}

variable "ou_workloads_prod_name" {
  type    = string
  default = "Workloads-Prod-OU"
}

variable "ou_workloads_nonprod_name" {
  type    = string
  default = "Workloads-NonProd-OU"
}

variable "ou_sandbox_name" {
  type    = string
  default = "Sandbox-OU"
}

variable "log_archive_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.log_archive_account_email, "<") && !strcontains(var.log_archive_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "security_tooling_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.security_tooling_account_email, "<") && !strcontains(var.security_tooling_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "network_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.network_account_email, "<") && !strcontains(var.network_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "production_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.production_account_email, "<") && !strcontains(var.production_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "staging_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.staging_account_email, "<") && !strcontains(var.staging_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "development_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.development_account_email, "<") && !strcontains(var.development_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "shared_system_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.shared_system_account_email, "<") && !strcontains(var.shared_system_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "sandbox_account_email" {
  type = string

  validation {
    condition     = !strcontains(var.sandbox_account_email, "<") && !strcontains(var.sandbox_account_email, ">")
    error_message = "Replace the email placeholder with a real, unique account email."
  }
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for the bootstrap state only."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "Use a 3-63 character globally unique S3 bucket name with lowercase letters, numbers, and hyphens."
  }
}

variable "lock_table_name" {
  description = "DynamoDB lock table used only by the bootstrap state."
  type        = string
  default     = "enterprise-landing-zone-locks"
}

variable "environment_state_bucket_prefix" {
  description = "Globally unique lowercase prefix for per-environment state buckets."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.environment_state_bucket_prefix))
    error_message = "Use a 3-32 character lowercase bucket prefix containing only letters, numbers, and hyphens; it must start and end with a letter or number."
  }
}

variable "state_backend_trusted_principal_arns" {
  description = "One existing IAM role ARN allowed to assume the state access role for each environment."
  type        = map(string)

  validation {
    condition = length(var.state_backend_trusted_principal_arns) == 9 && alltrue([
      for environment in ["management", "security", "log-archive", "network", "shared-services", "workload-dev", "workload-stage", "workload-prod", "sandbox"] :
      contains(keys(var.state_backend_trusted_principal_arns), environment)
    ])
    error_message = "Provide exactly one trusted principal ARN for every environment backend."
  }

  validation {
    condition = alltrue([
      for principal_arn in values(var.state_backend_trusted_principal_arns) :
      can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", principal_arn))
    ])
    error_message = "Replace every principal placeholder with an existing IAM role ARN."
  }

  validation {
    condition     = length(toset(values(var.state_backend_trusted_principal_arns))) == 9
    error_message = "Use a different trusted source role for each environment to preserve state isolation."
  }
}
