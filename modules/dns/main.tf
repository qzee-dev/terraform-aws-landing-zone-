resource "aws_route53_zone" "private" {
  name = var.private_zone_name

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_resolver_endpoint" "inbound" {
  direction = "INBOUND"
  name      = "resolver-inbound"

  security_group_ids = [var.security_group_id]
  dynamic "ip_address" {
    for_each = var.inbound_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  direction = "OUTBOUND"
  name      = "resolver-outbound"

  security_group_ids = [var.security_group_id]
  dynamic "ip_address" {
    for_each = var.outbound_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }
}
