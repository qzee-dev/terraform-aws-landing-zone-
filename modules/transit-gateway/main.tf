resource "aws_ec2_transit_gateway" "this" {
  description                     = "Enterprise core TGW"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name        = "enterprise-core-tgw"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  subnet_ids         = var.inspection_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = var.inspection_vpc_id
}

resource "aws_ram_resource_share" "transit_gateway" {
  name                      = "landing-zone-transit-gateway"
  allow_external_principals = false

  tags = {
    Name        = "landing-zone-transit-gateway"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_ram_resource_association" "transit_gateway" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.transit_gateway.arn
}

resource "aws_ram_principal_association" "accounts" {
  for_each = var.spoke_account_ids

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.transit_gateway.arn
}
