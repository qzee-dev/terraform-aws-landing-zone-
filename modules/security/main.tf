data "aws_partition" "current" {}

resource "aws_securityhub_account" "this" {
  auto_enable_controls = true
}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = false
  auto_enable_standards = "NONE"

  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [aws_securityhub_finding_aggregator.organization]
}

resource "aws_securityhub_finding_aggregator" "organization" {
  linking_mode = "ALL_REGIONS"

  depends_on = [aws_securityhub_account.this]
}

resource "aws_securityhub_configuration_policy" "organization" {
  name        = "organization-baseline"
  description = "Enable Security Hub and AWS Foundational Security Best Practices across the organization."

  configuration_policy {
    service_enabled = true
    enabled_standard_arns = [
      "arn:${data.aws_partition.current.partition}:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
    ]

    security_controls_configuration {
      disabled_control_identifiers = []
    }
  }

  depends_on = [aws_securityhub_organization_configuration.this]
}

resource "aws_securityhub_configuration_policy_association" "organization" {
  target_id = var.organization_root_id
  policy_id = aws_securityhub_configuration_policy.organization.id
}

resource "aws_guardduty_detector" "this" {
  enable = true
}

resource "aws_guardduty_organization_configuration" "this" {
  detector_id                      = aws_guardduty_detector.this.id
  auto_enable_organization_members = "ALL"
}

resource "aws_iam_role" "config_organization_aggregator" {
  name = "AWSConfigOrganizationAggregator"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_organization_aggregator" {
  role       = aws_iam_role.config_organization_aggregator.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_aggregator" "organization" {
  name = "organization-config-aggregator"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_organization_aggregator.arn
  }

  depends_on = [aws_iam_role_policy_attachment.config_organization_aggregator]
}
