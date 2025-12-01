<h1>OVERVIEW</h1>

This project implements a complete, security-focused monitoring pipeline on AWS using Terraform. It tracks all access attempts to a sensitive Secrets Manager secret through CloudTrail, analyzes events in CloudWatch Logs using metric filters, and triggers real-time alerts via SNS whenever the secret is accessed. The entire system — **secret creation, CloudTrail logging, S3 storage, log groups, metric filters, alarms,** and **notification setup** — is deployed end-to-end with Infrastructure as Code, following industry practices for auditability and security monitoring.

<h1>FEATURES</h1>

- Monitors secret access (GetSecretValue) in real time.

- Uses CloudTrail to capture access events across AWS.

- Pushes all CloudTrail logs into CloudWatch Logs for analysis.

- Applies CloudWatch Metric Filters to detect secret access events.

- Triggers SNS alerts immediately when the secret is accessed.

- Fully declarative deployment using Terraform (stepwise).

- Designed with auditability, traceability, and security visibility in mind.
