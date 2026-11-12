variable "management_account_id" {
  type    = string
  default = ""
}

variable "aws_region" {
  description = "Region used for Security Hub standard subscription."
  type        = string
}

variable "organization_root_id" {
  description = "Organizations root ID associated with the Security Hub policy."
  type        = string
}
