<h1>OVERVIEW</h1>

This project implements a complete, security-focused monitoring pipeline on AWS using Terraform. It tracks all access attempts to a sensitive Secrets Manager secret through CloudTrail, analyzes events in CloudWatch Logs using metric filters, and triggers real-time alerts via SNS whenever the secret is accessed. The entire system — **secret creation, CloudTrail logging, S3 storage, log groups, metric filters, alarms,** and **notification setup** — is deployed end-to-end with Infrastructure as Code, following industry practices for auditability and security monitoring.
