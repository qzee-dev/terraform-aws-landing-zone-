output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.this.id
}

output "route_table_id" {
  value = aws_ec2_transit_gateway_route_table.default.id
}
