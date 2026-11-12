output "security_alerts_topic_arn" {
  description = "SNS topic receiving high-severity GuardDuty and Security Hub findings."
  value       = aws_sns_topic.security_alerts.arn
}
