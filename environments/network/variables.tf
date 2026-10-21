variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "network"
}

variable "project_name" {
  type    = string
  default = "medical-platform"
}

variable "onprem_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

variable "prod_subnet_ids" {
  type    = list(string)
  default = ["subnet-00000000000000001"]
}

variable "stage_subnet_ids" {
  type    = list(string)
  default = ["subnet-00000000000000002"]
}

variable "dev_subnet_ids" {
  type    = list(string)
  default = ["subnet-00000000000000003"]
}

variable "inspection_subnet_ids" {
  type    = list(string)
  default = ["subnet-00000000000000004"]
}

variable "shared_services_subnet_ids" {
  type    = list(string)
  default = ["subnet-00000000000000005"]
}
