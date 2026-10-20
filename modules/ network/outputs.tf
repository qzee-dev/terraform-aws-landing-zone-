output "inspection_vpc_id" {
  value = aws_vpc.inspection.id
}

output "shared_services_vpc_id" {
  value = aws_vpc.shared_services.id
}

output "prod_vpc_id" {
  value = aws_vpc.prod.id
}

output "stage_vpc_id" {
  value = aws_vpc.stage.id
}

output "dev_vpc_id" {
  value = aws_vpc.dev.id
}
