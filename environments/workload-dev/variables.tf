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

variable "transit_gateway_id" {
  description = "Transit Gateway ID output by the network environment."
  type        = string
}

variable "transit_route_cidrs" {
  description = "Approved internal or on-premises CIDRs routed to the Transit Gateway."
  type        = set(string)
}

variable "vpc_cidr" {
  description = "Non-overlapping CIDR block for the development VPC."
  type        = string
  default     = "10.70.0.0/16"
}
