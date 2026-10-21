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
