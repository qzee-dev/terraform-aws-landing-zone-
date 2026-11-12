variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "expected_account_id" {
  description = "AWS account ID expected to run this environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Use the actual 12-digit shared-services account ID."
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

variable "shared_services_vpc_cidr" {
  description = "CIDR block for the shared-services VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "ad_password" {
  type      = string
  sensitive = true

  validation {
    condition     = !strcontains(var.ad_password, "<") && !strcontains(var.ad_password, ">")
    error_message = "Inject the real AD password through a secret manager or CI secret."
  }
}

variable "ad_directory_name" {
  description = "Fully qualified DNS name for AWS Managed Microsoft AD."
  type        = string

  validation {
    condition     = length(trimspace(var.ad_directory_name)) > 0 && !strcontains(var.ad_directory_name, "<")
    error_message = "Set the approved fully qualified AD DNS domain name."
  }
}

variable "dns_zone_name" {
  description = "Private DNS zone for the company."
  type        = string

  validation {
    condition     = !strcontains(var.dns_zone_name, "<") && !strcontains(var.dns_zone_name, ">")
    error_message = "Replace the DNS zone placeholder with the approved private domain."
  }
}
