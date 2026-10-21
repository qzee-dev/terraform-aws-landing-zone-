output "private_zone_id" {
  value = aws_route53_zone.private.id
}

output "resolver_inbound_endpoint_id" {
  value = aws_route53_resolver_endpoint.inbound.id
}

output "resolver_outbound_endpoint_id" {
  value = aws_route53_resolver_endpoint.outbound.id
}
