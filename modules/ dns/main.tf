resource "aws_route53_zone" "private" {
  name = "example.internal"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_resolver_endpoint" "inbound" {
  direction = "INBOUND"
  name      = "resolver-inbound"

  security_group_ids = [var.security_group_id]
  ip_address {
    subnet_id = var.inbound_subnet_id
  }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  direction = "OUTBOUND"
  name      = "resolver-outbound"

  security_group_ids = [var.security_group_id]
  ip_address {
    subnet_id = var.outbound_subnet_id
  }
}
