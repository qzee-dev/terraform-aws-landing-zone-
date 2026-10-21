resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids                                      = var.subnet_ids
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = var.vpc_id
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

resource "aws_route" "transit_gateway" {
  for_each = var.route_cidrs

  destination_cidr_block = each.value
  route_table_id         = var.route_table_id
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}