data "aws_caller_identity" "current" {}

resource "aws_flow_log" "inspection" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.inspection.id

  tags = {
    Name        = "inspection-flow-log"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_flow_log" "shared_services" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.shared_services.id

  tags = {
    Name        = "shared-services-flow-log"
    Environment = "SharedServices"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_flow_log" "prod" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.prod.id

  tags = {
    Name        = "prod-flow-log"
    Environment = "Prod"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_flow_log" "stage" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.stage.id

  tags = {
    Name        = "stage-flow-log"
    Environment = "Stage"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_flow_log" "dev" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.dev.id

  tags = {
    Name        = "dev-flow-log"
    Environment = "Dev"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 365

  tags = {
    Name        = "vpc-flow-logs"
    Environment = "Core"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}
