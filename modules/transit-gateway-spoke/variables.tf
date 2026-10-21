variable "transit_gateway_id" {
  description = "Transit Gateway ID shared from the network account."
  type        = string
}

variable "vpc_id" {
  description = "VPC to attach to the shared Transit Gateway."
  type        = string
}

variable "subnet_ids" {
  description = "One attachment subnet per Availability Zone."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two Transit Gateway attachment subnets are required."
  }
}

variable "route_table_id" {
  description = "VPC route table that should route approved CIDRs to the Transit Gateway."
  type        = string
}

variable "route_cidrs" {
  description = "Approved destination CIDRs reachable through the Transit Gateway."
  type        = set(string)

  validation {
    condition     = length(var.route_cidrs) > 0
    error_message = "At least one Transit Gateway destination CIDR must be configured."
  }
}