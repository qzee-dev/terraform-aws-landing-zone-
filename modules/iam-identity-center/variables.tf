variable "security_audit_group_id" {
  description = "IAM Identity Center group ID for security auditors."
  type        = string
  default     = ""
}

variable "network_admin_group_id" {
  description = "SSO group ID for network admins"
  type        = string
  default     = ""
}

variable "developer_group_id" {
  description = "IAM Identity Center group ID for developers assigned to the development account."
  type        = string
  default     = ""
}

variable "stage_readonly_group_id" {
  description = "IAM Identity Center group ID for staging read-only access."
  type        = string
  default     = ""
}

variable "prod_readonly_group_id" {
  description = "IAM Identity Center group ID for production read-only access."
  type        = string
  default     = ""
}

variable "platform_admin_group_id" {
  description = "Optional IAM Identity Center group ID for tightly controlled management-account administrators."
  type        = string
  default     = ""
}

variable "management_account_id" {
  description = "AWS Organizations management account ID."
  type        = string
}

variable "security_account_id" {
  description = "Security tooling account ID"
  type        = string
}

variable "network_account_id" {
  description = "Network account ID"
  type        = string
}

variable "development_account_id" {
  description = "Development workload account ID."
  type        = string
}

variable "staging_account_id" {
  description = "Staging workload account ID."
  type        = string
}

variable "production_account_id" {
  description = "Production workload account ID."
  type        = string
}
