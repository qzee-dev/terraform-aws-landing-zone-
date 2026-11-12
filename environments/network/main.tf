terraform {
  required_version = ">= 1.10.0"
  backend "s3" {}
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]

  assume_role {
    role_arn = var.terraform_role_arn
  }
}

module "network" {
  source = "../../modules/network"

  vpcs = {
    inspection = {
      cidr_block  = var.inspection_vpc_cidr
      environment = "Core"
    }
  }
}

module "transit_gateway" {
  source = "../../modules/transit-gateway"

  inspection_vpc_id     = module.network.vpc_ids["inspection"]
  inspection_subnet_ids = module.network.subnet_ids["inspection"]
  spoke_account_ids     = var.transit_gateway_spoke_account_ids
}

locals {
  inspection_attachment_subnets = {
    for index, subnet_id in module.network.subnet_ids["inspection"] :
    module.network.subnet_availability_zones["inspection"][index] => {
      index     = index
      subnet_id = subnet_id
    }
  }

  inspection_peer_cidrs = setunion(var.inspection_peer_cidrs, [var.inspection_vpc_cidr])

  inspection_acl_rules = {
    for index, cidr in sort(tolist(local.inspection_peer_cidrs)) :
    tostring(100 + index) => cidr
  }

  firewall_routes = {
    for route in setproduct(keys(aws_subnet.inspection_firewall), var.inspection_peer_cidrs) :
    "${route[0]}|${route[1]}" => {
      availability_zone = route[0]
      cidr              = route[1]
    }
  }

  firewall_endpoint_by_az = {
    for sync_state in aws_networkfirewall_firewall.inspection.firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
  }
}

resource "aws_subnet" "inspection_firewall" {
  for_each = local.inspection_attachment_subnets

  vpc_id                  = module.network.vpc_ids["inspection"]
  cidr_block              = cidrsubnet(var.inspection_vpc_cidr, 8, 20 + each.value.index)
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name        = "inspection-firewall-${each.value.index + 1}"
    Environment = "Core"
    Automation  = "Terraform"
  }
}

resource "aws_network_acl" "inspection" {
  vpc_id = module.network.vpc_ids["inspection"]

  tags = {
    Name        = "inspection-subnet-nacl"
    Environment = "Core"
    Automation  = "Terraform"
  }
}

resource "aws_network_acl_rule" "inspection_ingress" {
  for_each = local.inspection_acl_rules

  network_acl_id = aws_network_acl.inspection.id
  rule_number    = tonumber(each.key)
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = each.value
}

resource "aws_network_acl_rule" "inspection_egress" {
  for_each = local.inspection_acl_rules

  network_acl_id = aws_network_acl.inspection.id
  rule_number    = tonumber(each.key)
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = each.value
}

resource "aws_network_acl_association" "inspection" {
  for_each = toset(concat(
    module.network.subnet_ids["inspection"],
    [for subnet in aws_subnet.inspection_firewall : subnet.id],
  ))

  subnet_id      = each.value
  network_acl_id = aws_network_acl.inspection.id
}

resource "aws_networkfirewall_rule_group" "inspection" {
  capacity = 100
  name     = "inspection-default-deny"
  type     = "STATEFUL"

  rules = join("\n", concat(
    var.inspection_stateful_allow_rules,
    ["drop ip any any -> any any (msg:\"Default deny\"; sid:900000001; rev:1;)"],
  ))

  tags = {
    Name        = "inspection-default-deny"
    Environment = "Core"
    Automation  = "Terraform"
  }
}

resource "aws_networkfirewall_firewall_policy" "inspection" {
  name = "inspection-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_default_actions           = ["aws:drop_strict"]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
      priority     = 100
      resource_arn = aws_networkfirewall_rule_group.inspection.arn
    }
  }

  tags = {
    Name        = "inspection-policy"
    Environment = "Core"
    Automation  = "Terraform"
  }
}

resource "aws_networkfirewall_firewall" "inspection" {
  name                              = "inspection-firewall"
  description                       = "Central stateful inspection for Transit Gateway spoke traffic."
  firewall_policy_arn               = aws_networkfirewall_firewall_policy.inspection.arn
  vpc_id                            = module.network.vpc_ids["inspection"]
  delete_protection                 = true
  firewall_policy_change_protection = true
  subnet_change_protection          = true

  dynamic "subnet_mapping" {
    for_each = aws_subnet.inspection_firewall

    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = {
    Name        = "inspection-firewall"
    Environment = "Core"
    Automation  = "Terraform"
  }
}

resource "aws_route_table" "inspection_attachment" {
  for_each = local.inspection_attachment_subnets

  vpc_id = module.network.vpc_ids["inspection"]

  tags = {
    Name        = "inspection-tgw-${each.value.index + 1}-rt"
    Environment = "Core"
    Automation  = "Terraform"
  }
}

resource "aws_route_table_association" "inspection_attachment" {
  for_each = local.inspection_attachment_subnets

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.inspection_attachment[each.key].id
}

resource "aws_route" "inspection_attachment_to_firewall" {
  for_each = local.inspection_attachment_subnets

  route_table_id         = aws_route_table.inspection_attachment[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoint_by_az[each.key]

  depends_on = [aws_networkfirewall_firewall.inspection]
}

resource "aws_route_table" "inspection_firewall" {
  for_each = aws_subnet.inspection_firewall

  vpc_id = module.network.vpc_ids["inspection"]

  tags = {
    Name        = "inspection-firewall-${each.value.availability_zone}-rt"
    Environment = "Core"
    Automation  = "Terraform"
  }
}

resource "aws_route_table_association" "inspection_firewall" {
  for_each = aws_subnet.inspection_firewall

  subnet_id      = each.value.id
  route_table_id = aws_route_table.inspection_firewall[each.key].id
}

resource "aws_route" "firewall_to_spokes" {
  for_each = local.firewall_routes

  route_table_id         = aws_route_table.inspection_firewall[each.value.availability_zone].id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}

resource "aws_cloudwatch_log_group" "network_firewall_flow" {
  name              = "/aws/network-firewall/inspection/flow"
  retention_in_days = var.network_firewall_log_retention_days
}

resource "aws_cloudwatch_log_group" "network_firewall_alert" {
  name              = "/aws/network-firewall/inspection/alert"
  retention_in_days = var.network_firewall_log_retention_days
}

resource "aws_networkfirewall_logging_configuration" "inspection" {
  firewall_arn                = aws_networkfirewall_firewall.inspection.arn
  enable_monitoring_dashboard = true

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall_flow.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall_alert.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "spokes" {
  for_each = var.transit_gateway_spoke_attachment_ids

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = module.transit_gateway.route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spokes_to_inspection" {
  for_each = var.transit_gateway_spoke_attachment_ids

  transit_gateway_attachment_id  = each.value
  transit_gateway_route_table_id = module.transit_gateway.inspection_route_table_id
}

module "config_recorder" {
  source = "../../modules/config-recorder"
}
