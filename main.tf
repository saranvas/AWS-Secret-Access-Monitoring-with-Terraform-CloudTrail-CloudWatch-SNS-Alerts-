terraform {
    required_version = ">= 1.5.0"
    required_providers {

      aws = { source = "hashicorp/aws" , version = ">=4.0"}
      random = { source = "hashicorp/random" , version = ">=3.0"}
    }
}

provider "aws" {
    region = var.aws_region
}



resource "aws_secretsmanager_secret" "TopSecret" {
  name = var.secret_name
  description = "This secret is monitored by Cloudtrail"
  tags = {env = var.env}
}

resource "aws_secretsmanager_secret_version" "TopSecret_version" {
    secret_id = aws_secretsmanager_secret.TopSecret.id
    secret_string = jsonencode( {api_key = "123455334", description = " Key for api"})
}



resource "aws_sns_topic" "alerts"{
    name = "${var.env}-secret-alerts"
    tags = { env = var.env}
}



resource "aws_sns_topic" "alerts"{
    name = "${var.env}-secret-alerts"
    tags = { env = var.env}
}

resource "aws_sns_topic_subscription" "email_sub" {
    topic_arn = aws_sns_topic.alerts.arn
    protocol = "email"
    endpoint = var.notification_email
}


resource "random_id" "bucket_suffix" {byte_length = 4}

resource "aws_s3_bucket" "trail_bucket" {
  bucket = "${var.env}-trail-bucket-${random_id.bucket_suffix.hex}"

    tags = {env = var.env}
}

resource "aws_s3_bucket_versioning" "trail_bucket_versioning" {
  bucket = aws_s3_bucket.trail_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail_bucket_sse" {
  bucket = aws_s3_bucket.trail_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}




data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "trail_bucket_policy" {
  bucket = aws_s3_bucket.trail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.trail_bucket.arn
         },
      {
        Sid = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.trail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}




resource "aws_cloudwatch_log_group" "cloudtrail_group" {
    name = "${var.cloudtrail_name}"
    tags = {env = var.env}
}


resource "aws_iam_role" "ct_cw_role"{
    name = "${var.env}-cloudtrail-cw-role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy" "cloudtrail_cw_policy"{
    name = "${var.env}-cloudtrail-cw-policy"
    role = aws_iam_role.ct_cw_role.id
    policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["logs:CreateLogStream","logs:PutLogEvents","logs:CreateLogGroup","logs:DescribeLogGroups","logs:DescribeLogStreams"]
            Resource = "${aws_cloudwatch_log_group.cloudtrail_group.arn}:*"

        },
        {
            Effect = "Allow", Action = ["s3:GetBucketAcl","s3:GetBucketLocation"], Resource = "*"
        }]
    })
}


resource "aws_cloudtrail" "trail" {
    name = var.cloudtrail_name
    s3_bucket_name = aws_s3_bucket.trail_bucket.id
    include_global_service_events = true
    is_multi_region_trail = true
    enable_logging = true
    cloud_watch_logs_group_arn ="${aws_cloudwatch_log_group.cloudtrail_group.arn}:*"
    cloud_watch_logs_role_arn = aws_iam_role.ct_cw_role.arn

    event_selector {
      read_write_type = "All"
      include_management_events = true
      data_resource {
        values = ["arn:aws:s3:::${aws_s3_bucket.trail_bucket.bucket}/"]
        type = "AWS::S3::Object"
      }
    }
    tags = {env=var.env}
}


resource "aws_cloudwatch_log_metric_filter" "get_secret_value_filter" {
    name = "${var.env}-get-secretvalue-filter"
    log_group_name = aws_cloudwatch_log_group.cloudtrail_group.name
    pattern = <<PATTERN
{ ($.eventName = "GetSecretValue") && ($.requestParameters.name = "${var.secret_name}")}
PATTERN

    metric_transformation {
        name = "${var.env}_get_secretvalue_count"
        namespace = "SecretMonitoring"
        value = "1"
    }
}


resource "aws_cloudwatch_metric_alarm" "secret_access_alarm" {
alarm_name = "${var.env}-secret-access-alarm"
alarm_description = "Alarm when the monitored secret is accessed"
comparison_operator = "GreaterThanOrEqualToThreshold"
evaluation_periods = 1
metric_name = aws_cloudwatch_log_metric_filter.get_secret_value_filter.metric_transformation[0].name
namespace = aws_cloudwatch_log_metric_filter.get_secret_value_filter.metric_transformation[0].namespace
period = 300
statistic = "Sum"
threshold = 1
alarm_actions = [aws_sns_topic.alerts.arn]
ok_actions = [aws_sns_topic.alerts.arn]
treat_missing_data = "notBreaching"
tags = { env = var.env }
}


