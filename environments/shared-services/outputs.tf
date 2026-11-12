output "active_directory_id" {
  description = "AWS Directory Service ID to select when connecting AD to IAM Identity Center."
  value       = module.active_directory.directory_id
}

output "transit_gateway_attachment_id" {
  value = module.transit_gateway_spoke.attachment_id
}
