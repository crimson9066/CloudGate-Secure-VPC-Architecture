# Terraform implementation

This directory contains the CloudGate AWS infrastructure. Run Terraform commands from here.

## Important variables

- `enable_vpc_flow_logs`: deliver VPC traffic metadata to CloudWatch Logs
- `enable_security_services`: enable GuardDuty, Security Hub, and AWS Config
- `enable_cloudtrail`: enable encrypted, validated CloudTrail delivery
- `enable_ssm_vpc_endpoints`: keep Session Manager traffic private
- `enable_sample_application`: deploy the optional ALB and private Auto Scaling group
- `enable_sample_database`: deploy an encrypted private PostgreSQL database

All optional controls are disabled by default to make cost and account-level changes explicit. Review the root [README](../README.md), [security policy](../SECURITY.md), and [threat model](../docs/threat-model.md) before enabling them.
