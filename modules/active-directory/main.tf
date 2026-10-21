resource "aws_directory_service_directory" "this" {
  name        = "corp.example.internal"
  password    = var.password
  size        = "Small"
  type        = "MicrosoftAD"
  description = "Shared Services AD"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  tags = {
    Name        = "shared-services-ad"
    Environment = "SharedServices"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}
