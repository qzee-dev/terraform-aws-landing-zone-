variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "expected_account_id" {
  description = "AWS account ID expected to run this environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Use the actual 12-digit production account ID."
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

variable "transit_gateway_id" {
  description = "Transit Gateway ID output by the network environment."
  type        = string

  validation {
    condition     = can(regex("^tgw-[0-9a-f]{17}$", var.transit_gateway_id))
    error_message = "Use the Transit Gateway ID output by the network environment."
  }
}

variable "transit_route_cidrs" {
  description = "Approved internal or on-premises CIDRs routed to the Transit Gateway."
  type        = set(string)
}

variable "db_password" {
  type      = string
  sensitive = true

  validation {
    condition     = !strcontains(var.db_password, "<") && !strcontains(var.db_password, ">")
    error_message = "Inject the real database password through a secret manager or CI secret."
  }
}
