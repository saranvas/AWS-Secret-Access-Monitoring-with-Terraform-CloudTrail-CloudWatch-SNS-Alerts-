output "secret_arn" {
    value = aws_secretsmanager_secret.TopSecret.arn
    }

output "cloudtrail_name"{
    value = aws_cloudtrail.trail.name
}

output "cloudwatch_log_group" {
    value = aws_cloudwatch_log_group.cloudtrail_group.name
}


output "sns_topic_arn" {
    value = aws_sns_topic.alerts.arn
}

