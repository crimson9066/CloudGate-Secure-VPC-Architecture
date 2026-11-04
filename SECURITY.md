# Security policy

This repository is a portfolio demonstration and is not a managed production service.

## Reporting a vulnerability

Please do not publish credentials, keys, or exploitable details in a public issue. Use GitHub's private vulnerability reporting if enabled, or contact the repository owner privately.

## Security design

- Administrative access uses AWS Systems Manager Session Manager; public SSH is intentionally disabled.
- IMDSv2 is required for EC2 instances.
- Private application instances accept traffic only from the load balancer security group.
- Optional VPC Flow Logs, GuardDuty, Security Hub, and AWS Config controls are disabled by default to avoid unexpected account-level cost and are enabled explicitly through Terraform variables.
- Terraform state must be stored in an encrypted, access-controlled remote backend for shared environments.

Never commit `terraform.tfvars`, private keys, credentials, or Terraform state.
