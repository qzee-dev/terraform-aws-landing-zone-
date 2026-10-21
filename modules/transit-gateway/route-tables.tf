resource "aws_ec2_transit_gateway_route_table" "default" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name        = "landing-zone-tgw-rt"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_association" "shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_association" "prod" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_association" "stage" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.stage.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_association" "dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inspection" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "stage" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.stage.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dev" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

resource "aws_ec2_transit_gateway_route" "onprem" {
  count                          = length(var.onprem_cidrs)
  destination_cidr_block         = var.onprem_cidrs[count.index]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
  blackhole                     = false
}
