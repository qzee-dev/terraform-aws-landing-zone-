variable "directory_name" {
  description = "Fully qualified DNS name for the AWS Managed Microsoft AD directory."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "password" {
  type      = string
  sensitive = true
}
