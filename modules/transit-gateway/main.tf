resource "aws_ec2_transit_gateway" "this" {
  description                    = "Enterprise core TGW"
  auto_accept_shared_attachments = "enable"

  tags = {
    Name        = "enterprise-core-tgw"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_ec2_transit_gateway_route_table" "default" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod" {
  subnet_ids = var.prod_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id = var.prod_vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "stage" {
  subnet_ids = var.stage_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id = var.stage_vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev" {
  subnet_ids = var.dev_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id = var.dev_vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  subnet_ids = var.inspection_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id = var.inspection_vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shared" {
  subnet_ids = var.shared_services_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id = var.shared_services_vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}
