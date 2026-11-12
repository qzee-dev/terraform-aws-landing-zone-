output "transit_gateway_id" {
  value = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_route_table_id" {
  value = module.transit_gateway.route_table_id
}

output "transit_gateway_inspection_route_table_id" {
  value = module.transit_gateway.inspection_route_table_id
}

output "inspection_firewall_endpoint_ids" {
  value = {
    for availability_zone, endpoint_id in local.firewall_endpoint_by_az :
    availability_zone => endpoint_id
  }
}