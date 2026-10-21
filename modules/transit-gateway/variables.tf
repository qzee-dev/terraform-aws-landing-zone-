variable "inspection_vpc_id" {
  type = string
}

variable "inspection_subnet_ids" {
  type = list(string)
}

variable "spoke_account_ids" {
  description = "AWS account IDs authorized to attach VPCs to this Transit Gateway."
  type        = set(string)

  validation {
    condition     = length(var.spoke_account_ids) > 0
    error_message = "At least one spoke account ID must be authorized."
  }
}
