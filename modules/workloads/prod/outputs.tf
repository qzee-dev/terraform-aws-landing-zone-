output "vpc_id" {
  value = aws_vpc.prod.id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

output "route_table_id" {
  value = aws_vpc.prod.default_route_table_id
}

output "db_instance_id" {
  value = aws_db_instance.primary.id
}
