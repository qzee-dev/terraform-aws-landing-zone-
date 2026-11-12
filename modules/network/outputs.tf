output "vpc_ids" {
  value = { for name, vpc in aws_vpc.this : name => vpc.id }
}

output "subnet_ids" {
  value = {
    for name in keys(var.vpcs) : name => [
      for index in range(2) : aws_subnet.private["${name}-${index}"].id
    ]
  }
}

output "subnet_availability_zones" {
  value = {
    for name in keys(var.vpcs) : name => [
      for index in range(2) : aws_subnet.private["${name}-${index}"].availability_zone
    ]
  }
}

output "route_table_ids" {
  value = { for name, route_table in aws_route_table.private : name => route_table.id }
}
