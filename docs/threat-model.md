# Threat model

| Threat | Control | Evidence |
|---|---|---|
| Internet scanning of management ports | No SSH ingress; Session Manager | `security_groups.tf`, `bastion.tf` |
| Credential theft through instance metadata | IMDSv2 required | `bastion.tf`, `sample_application.tf` |
| Public application reaching private hosts directly | ALB-to-application security-group reference | `sample_application.tf` |
| Lateral movement across subnets | Segmented route tables and least-privilege SGs | `vpc.tf`, `security_groups.tf` |
| Undetected network activity | Optional VPC Flow Logs, GuardDuty, Security Hub | `logging.tf`, `security_services.tf` |
| IaC misconfiguration or leaked secrets | CI validation, Checkov, Trivy, Gitleaks | `.github/workflows/terraform-security.yml` |

## Residual risk

The default configuration is intentionally cost-conscious. Enable flow logs and account-level security services in a dedicated AWS account or approved environment. Add an encrypted remote Terraform backend, centralized CloudTrail, alert routing, backup policy, and incident-response runbooks before production use.
