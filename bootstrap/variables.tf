variable "aws_region" {
  description = "Primary AWS region."
  type        = string
  default     = "us-east-1"
}

variable "expected_management_account_id" {
  description = "AWS account ID expected to run the bootstrap stack."
  type        = string
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
}

variable "security_tooling_account_email" {
  type = string
}

variable "network_account_email" {
  type = string
}

variable "production_account_email" {
  type = string
}

variable "staging_account_email" {
  type = string
}

variable "development_account_email" {
  type = string
}

variable "shared_system_account_email" {
  type = string
}

variable "sandbox_account_email" {
  type = string
}

variable "state_bucket_name" {
  type = string
}

variable "lock_table_name" {
  type    = string
  default = "enterprise-landing-zone-locks"
}
