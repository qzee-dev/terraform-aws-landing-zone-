variable "vpc_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "inbound_subnet_ids" {
  type = list(string)

  validation {
    condition     = length(var.inbound_subnet_ids) >= 2
    error_message = "At least two inbound resolver subnet IDs are required."
  }
}

variable "outbound_subnet_ids" {
  type = list(string)

  validation {
    condition     = length(var.outbound_subnet_ids) >= 2
    error_message = "At least two outbound resolver subnet IDs are required."
  }
}
