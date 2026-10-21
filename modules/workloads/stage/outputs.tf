output "vpc_id" {
  value = aws_vpc.stage.id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

output "route_table_id" {
  value = aws_vpc.stage.default_route_table_id
}
