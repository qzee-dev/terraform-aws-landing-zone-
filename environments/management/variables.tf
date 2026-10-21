variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "expected_account_id" {
  description = "AWS account ID expected to run this environment."
  type        = string
}

variable "terraform_role_arn" {
  description = "Role assumed to manage this AWS account."
  type        = string
}

variable "security_admin_group_id" {
  description = "IAM Identity Center group ID for security administrators."
  type        = string
}

variable "network_admin_group_id" {
  description = "IAM Identity Center group ID for network administrators."
  type        = string
}

variable "security_account_id" {
  description = "Security tooling account ID output by bootstrap."
  type        = string
}

variable "network_account_id" {
  description = "Network account ID output by bootstrap."
  type        = string
}
