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

module "security" {
  source = "../../modules/security"

  management_account_id = var.management_account_id
  organization_root_id  = var.organization_root_id
  aws_region            = var.aws_region
}

module "config_recorder" {
  source = "../../modules/config-recorder"
}

resource "aws_sns_topic" "security_alerts" {
  name              = "landing-zone-security-alerts"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_cloudwatch_event_rule" "guardduty_high_severity" {
  name        = "guardduty-high-severity-findings"
  description = "Routes GuardDuty findings with severity 7 or higher to the security alert topic."

  event_pattern = jsonencode({
    source        = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]
    }
  })
}

resource "aws_cloudwatch_event_rule" "security_hub_high_severity" {
  name        = "security-hub-high-severity-findings"
  description = "Routes active HIGH and CRITICAL Security Hub findings to the security alert topic."

  event_pattern = jsonencode({
    source        = ["aws.securityhub"]
    "detail-type" = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        RecordState = ["ACTIVE"]
        Severity = {
          Label = ["HIGH", "CRITICAL"]
        }
      }
    }
  })
}

resource "aws_sns_topic_policy" "security_alerts" {
  arn = aws_sns_topic.security_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgeSecurityFindingDelivery"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.security_alerts.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.expected_account_id
          }
          ArnEquals = {
            "aws:SourceArn" = [
              aws_cloudwatch_event_rule.guardduty_high_severity.arn,
              aws_cloudwatch_event_rule.security_hub_high_severity.arn,
            ]
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "guardduty_security_alerts" {
  rule      = aws_cloudwatch_event_rule.guardduty_high_severity.name
  target_id = "security-alerts-sns"
  arn       = aws_sns_topic.security_alerts.arn

  depends_on = [aws_sns_topic_policy.security_alerts]
}

resource "aws_cloudwatch_event_target" "security_hub_security_alerts" {
  rule      = aws_cloudwatch_event_rule.security_hub_high_severity.name
  target_id = "security-alerts-sns"
  arn       = aws_sns_topic.security_alerts.arn

  depends_on = [aws_sns_topic_policy.security_alerts]
}

resource "aws_sns_topic_subscription" "security_alert_email" {
  count     = var.security_alert_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.security_alert_email
}
