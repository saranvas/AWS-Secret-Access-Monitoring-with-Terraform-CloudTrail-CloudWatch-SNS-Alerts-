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

 Trigger a secret access:

 *aws secretsmanager get-secret-value --secret-id my-sensitive-secret*


Within a short time:

CloudTrail logs the event.

CloudWatch metric filter matches it.

Alarm transitions → SNS sends alert.




  
