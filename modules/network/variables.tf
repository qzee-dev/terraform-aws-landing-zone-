variable "vpcs" {
  description = "VPCs owned by the calling account, keyed by stable logical name."
  type = map(object({
    cidr_block  = string
    environment = string
  }))

  validation {
    condition     = length(var.vpcs) > 0
    error_message = "At least one VPC definition is required."
  }
}
