output "vpc_id" {
  value = aws_vpc.prod.id
}

output "db_instance_id" {
  value = aws_db_instance.primary.id
}
