variable "prod_vpc_id" {
  type = string
}

variable "stage_vpc_id" {
  type = string
}

variable "dev_vpc_id" {
  type = string
}

variable "inspection_vpc_id" {
  type = string
}

variable "shared_services_vpc_id" {
  type = string
}

variable "prod_subnet_ids" {
  type = list(string)
}

variable "stage_subnet_ids" {
  type = list(string)
}

variable "dev_subnet_ids" {
  type = list(string)
}

variable "inspection_subnet_ids" {
  type = list(string)
}

variable "shared_services_subnet_ids" {
  type = list(string)
}
