resource "aws_route_table" "private" {
  for_each = aws_vpc.this

  vpc_id = each.value.id

  tags = {
    Name        = "${each.key}-private-rt"
    Environment = var.vpcs[each.key].environment
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_main_route_table_association" "private" {
  for_each = aws_vpc.this

  vpc_id         = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
