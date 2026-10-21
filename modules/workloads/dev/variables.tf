variable "environment" {
  description = "Workload environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "Non-overlapping CIDR block for this workload VPC."
  type        = string
}
