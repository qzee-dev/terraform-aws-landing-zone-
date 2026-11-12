variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "expected_account_id" {
  description = "AWS account ID expected to run this environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Use the actual 12-digit network account ID."
  }
}

variable "terraform_role_arn" {
  description = "Role assumed to manage this AWS account."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.terraform_role_arn))
    error_message = "Use the actual IAM role ARN for this environment."
  }
}

variable "transit_gateway_spoke_account_ids" {
  description = "Workload and shared-services account IDs authorized through AWS RAM."
  type        = set(string)

  validation {
    condition     = length(var.transit_gateway_spoke_account_ids) > 0 && alltrue([for account_id in var.transit_gateway_spoke_account_ids : can(regex("^[0-9]{12}$", account_id))])
    error_message = "Provide real 12-digit spoke account IDs from bootstrap."
  }
}

variable "transit_gateway_spoke_attachment_ids" {
  description = "Spoke attachment IDs output by each spoke root; add them after those roots are applied."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for attachment_id in values(var.transit_gateway_spoke_attachment_ids) :
      can(regex("^tgw-attach-[0-9a-f]+$", attachment_id))
    ])
    error_message = "Use real Transit Gateway VPC attachment IDs from the spoke root outputs."
  }
}

variable "inspection_vpc_cidr" {
  description = "Approved CIDR for the inspection VPC; it must fit at least /28 firewall subnets."
  type        = string

  validation {
    condition = can(cidrnetmask(var.inspection_vpc_cidr)) && try(
      tonumber(split("/", var.inspection_vpc_cidr)[1]) >= 16 &&
      tonumber(split("/", var.inspection_vpc_cidr)[1]) <= 20,
      false,
    )
    error_message = "Use an approved IPv4 VPC CIDR between /16 and /20 for the inspection VPC."
  }
}

variable "inspection_peer_cidrs" {
  description = "Approved spoke/on-premises CIDRs reachable through the inspection firewall."
  type        = set(string)
  default     = []

  validation {
    condition = length(var.inspection_peer_cidrs) <= 19 && alltrue([
      for cidr in var.inspection_peer_cidrs :
      can(cidrnetmask(cidr)) &&
      !cidrcontains(var.inspection_vpc_cidr, cidrhost(cidr, 0)) &&
      !cidrcontains(cidr, cidrhost(var.inspection_vpc_cidr, 0))
    ])
    error_message = "Use at most 19 valid IPv4 peer CIDRs (the default NACL quota), none overlapping the inspection VPC CIDR."
  }
}

variable "inspection_stateful_allow_rules" {
  description = "Approved Suricata pass/drop/alert rules, evaluated before the built-in default-deny rule."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.inspection_stateful_allow_rules) <= 98 && alltrue([for rule in var.inspection_stateful_allow_rules : trimspace(rule) != ""])
    error_message = "Provide at most 98 non-empty Suricata rules; leave empty for deny-all inspection."
  }
}

variable "network_firewall_log_retention_days" {
  description = "CloudWatch retention for AWS Network Firewall flow and alert logs."
  type        = number
  default     = 365

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731,
      1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.network_firewall_log_retention_days)
    error_message = "Use a CloudWatch Logs supported retention period."
  }
}
