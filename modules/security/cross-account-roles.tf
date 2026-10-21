resource "aws_iam_role" "security_audit_role" {
  name = "SecurityAuditCrossAccountRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.management_account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "security_audit_role" {
  name = "SecurityAuditCrossAccountPolicy"
  role = aws_iam_role.security_audit_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:DescribeTrails",
          "config:Describe*",
          "guardduty:List*",
          "securityhub:Describe*",
          "iam:List*",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })
}
