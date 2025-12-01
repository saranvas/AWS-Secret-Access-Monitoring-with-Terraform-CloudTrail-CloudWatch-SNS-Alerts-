<h1>OVERVIEW</h1>

This project implements a complete, security-focused monitoring pipeline on AWS using Terraform. It tracks all access attempts to a sensitive Secrets Manager secret through CloudTrail, analyzes events in CloudWatch Logs using metric filters, and triggers real-time alerts via SNS whenever the secret is accessed. The entire system — **secret creation, CloudTrail logging, S3 storage, log groups, metric filters, alarms,** and **notification setup** — is deployed end-to-end with Infrastructure as Code, following industry practices for auditability and security monitoring.
<img width="9681" height="3354" alt="Code Analysis (2)" src="https://github.com/user-attachments/assets/4090788b-accc-4fcb-abc3-4babbee15c13" />


<h1>FEATURES</h1>

- Monitors secret access (GetSecretValue) in real time.

- Uses CloudTrail to capture access events across AWS.

- Pushes all CloudTrail logs into CloudWatch Logs for analysis.

- Applies CloudWatch Metric Filters to detect secret access events.

- Triggers SNS alerts immediately when the secret is accessed.

- Fully declarative deployment using Terraform (stepwise).

- Designed with auditability, traceability, and security visibility in mind.
  

  <h1>HOW IT WORKS ?</h1>


- A sensitive secret is created in Secrets Manager.
- CloudTrail records every API call, including secret reads.
- CloudTrail delivers its logs to an S3 bucket for long-term storage and simultaneously streams them into CloudWatch Logs for real-time analysis.
- A CloudWatch Logs metric filter detects secret access events.
- A CloudWatch Alarm triggers when the event count ≥ 1.
- SNS sends an immediate alert to the configured email.

  <h1>TESTING</h1>

- Trigger a secret access:

 *aws secretsmanager get-secret-value --secret-id <secret_name>*


- Within a short time:

- CloudTrail logs the event.

- CloudWatch metric filter matches it.

- Alarm transitions → SNS sends alert.

  <h1>DEMO OUTPUT</h1>
<h2>Secrets Manager</h2>
  <img width="1328" height="441" alt="Screenshot 2025-11-30 212341" src="https://github.com/user-attachments/assets/5139fadd-2af3-46bd-abc7-52aebacfe2ba" />
This screenshot shows the Secrets Manager entry for the sensitive secret being monitored. CloudTrail tracks every GetSecretValue access for this secret, and those events feed into the CloudWatch log group, metric filter, and alerting pipeline. The view confirms the secret ARN, description, and retrieval options.

  <h2>CloudWatch Metric Visualization</h2>
<img width="1363" height="487" alt="Screenshot 2025-11-30 201751" src="https://github.com/user-attachments/assets/37dec7db-ca40-4368-aa94-68277ea42df0" />

  The graph shows the custom metric (`dev_get_secretvalue_count`) created from CloudTrail logs. It increments on every Secrets Manager access, validating that the metric filter and log pipeline are functioning correctly.

  <h2>CloudWatch Log Group</h2>
  <img width="1151" height="473" alt="Screenshot 2025-11-30 202359" src="https://github.com/user-attachments/assets/b9d497bb-23d0-4248-bca4-8ebcc16f4726" />


  This screenshot shows the CloudTrail log group (secret-access-trail) where all API calls—including GetSecretValue events—are delivered.

  <h2>CloudWatch Logs</h2>

  <img width="1167" height="487" alt="Screenshot 2025-11-30 202611" src="https://github.com/user-attachments/assets/54d1d77c-6900-4b6c-96f7-48d50fbe9d11" />

This screenshot shows the raw CloudTrail log events inside the secret-access-trail log group. Each entry records a full API call—including GetSecretValue access—along with user identity, source IP, timestamp, and request parameters. These logs are what the metric filter scans to detect secret access and trigger alerts.

<h2>CloudTrail Event History</h2>

<img width="1348" height="485" alt="Screenshot 2025-11-30 211959" src="https://github.com/user-attachments/assets/1185bb6b-3864-4c27-a305-94710af946e1" />

This view shows CloudTrail capturing every GetSecretValue API call made against the monitored secret. Each row records who accessed the secret, when the access happened, and which resource was queried. This verifies that CloudTrail is correctly logging all secret reads before they flow into CloudWatch for alerting.


<h2>SNS Alert Subscription</h2>

<img width="5440" height="1004" alt="Code Analysis (3)" src="https://github.com/user-attachments/assets/5f384221-6242-43ff-9faf-2783584a9462" />

This screenshot shows the SNS topic dev-secret-alerts with a confirmed email subscription. Whenever the CloudWatch alarm detects a secret access event, it publishes a message to this topic, which then sends an immediate email alert to the configured endpoint. This confirms that the alerting pipeline is fully active and notifications are being delivered successfully.

<h2>CloudWatch Alarm Email Alerts</h2>

<img width="5320" height="1135" alt="Code Analysis (4)" src="https://github.com/user-attachments/assets/c891fa1d-b09c-459e-9593-32d34518e03d" />
These screenshots show the real-time email notifications sent by Amazon SNS whenever the CloudWatch alarm detects a Secrets Manager access event. The alert includes full context — alarm name, state change, threshold details, timestamp, and direct console links — proving that the monitoring pipeline is working end-to-end and immediately notifying on any secret retrieval activity.

  






  
