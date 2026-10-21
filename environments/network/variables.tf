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

variable "transit_gateway_spoke_account_ids" {
  description = "Workload and shared-services account IDs authorized through AWS RAM."
  type        = set(string)
}
