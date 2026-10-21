variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "shared-services"
}

variable "project_name" {
  type    = string
  default = "medical-platform"
}

variable "shared_services_subnet_ids" {
  type = list(string)
  default = [
    "subnet-00000000000000010",
    "subnet-00000000000000011"
  ]
}

variable "ad_password" {
  type      = string
  sensitive = true
  default   = "REPLACE_WITH_STRONG_PASSWORD"
}

variable "dns_security_group_id" {
  type    = string
  default = "sg-00000000000000000"
}

variable "dns_inbound_subnet_ids" {
  type    = list(string)
  default = ["subnet-00000000000000012", "subnet-00000000000000014"]
}

variable "dns_outbound_subnet_ids" {
  type    = list(string)
  default = ["subnet-00000000000000013", "subnet-00000000000000015"]
}
