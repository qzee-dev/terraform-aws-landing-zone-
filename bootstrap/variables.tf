variable "aws_region" {
  description = "Primary AWS region."
  type        = string
  default     = "us-east-1"
}

variable "organization_name" {
  description = "AWS Organization name."
  type        = string
  default     = "enterprise-org"
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

variable "management_account_email" {
  type    = string
  default = "management@example.com"
}

variable "log_archive_account_email" {
  type    = string
  default = "log-archive@example.com"
}

variable "security_tooling_account_email" {
  type    = string
  default = "security-tooling@example.com"
}

variable "network_account_email" {
  type    = string
  default = "network@example.com"
}

variable "production_account_email" {
  type    = string
  default = "prod@example.com"
}

variable "staging_account_email" {
  type    = string
  default = "staging@example.com"
}

variable "development_account_email" {
  type    = string
  default = "dev@example.com"
}

variable "shared_system_account_email" {
  type    = string
  default = "shared-system@example.com"
}

variable "sandbox_account_email" {
  type    = string
  default = "sandbox@example.com"
}

variable "state_bucket_name" {
  type    = string
  default = "enterprise-landing-zone-state"
}

variable "lock_table_name" {
  type    = string
  default = "enterprise-landing-zone-locks"
}
