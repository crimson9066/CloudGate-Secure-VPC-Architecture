# CloudGate Secure VPC Architecture

CloudGate is a security-focused AWS network foundation built with Terraform. It demonstrates how cloud infrastructure can be designed, delivered, and continuously checked using DevSecOps practices.

## What this demonstrates

- Multi-AZ public/private subnet segmentation
- Controlled routing through an Internet Gateway and NAT Gateway
- IAM-authenticated administration through AWS Systems Manager Session Manager from a private subnet
- No public SSH ingress by default
- IMDSv2 enforcement and encrypted EBS
- Optional private application tier behind a public Application Load Balancer
- Optional encrypted private PostgreSQL database with Secrets Manager credentials
- Optional VPC Flow Logs, GuardDuty, Security Hub, AWS Config, and private SSM endpoints
- Optional multi-region CloudTrail with log-file validation and protected S3 delivery
- CI security gates using Terraform validation, TFLint, Checkov, Trivy, and Gitleaks

See the [architecture](docs/architecture.md) and [threat model](docs/threat-model.md).

## Repository structure

```text
Terra-HCL/                         Terraform infrastructure
  vpc.tf                           VPC, subnets, routes, NAT
  bastion.tf                       SSM-managed administrative instance
  sample_application.tf            Optional ALB and private ASG
  sample_database.tf               Optional private PostgreSQL database
  logging.tf                       Optional VPC Flow Logs
  security_services.tf             Optional account-level detections
  ssm_endpoints.tf                 Optional private SSM endpoints
.github/workflows/                 CI security gates
docs/                              Architecture and threat model
SECURITY.md                        Security policy and operating boundaries
```

## Prerequisites

- Terraform 1.6+
- AWS CLI credentials with least-privilege deployment permissions
- An AWS account where optional account-level services are approved

## Deploy

```powershell
cd Terra-HCL
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit the region, AZs, and project settings.
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

The example configuration is safe by default: public SSH is rejected, optional security services are disabled, and the sample application is disabled. Enable expensive or account-level features deliberately in a dedicated environment.

After deployment, use the generated `bastion_ssm_command` output to start an administrative Session Manager shell. The optional application URL is available as `sample_application_url`.

## Engineering controls

Every pull request runs formatting, Terraform validation, linting, IaC scanning, vulnerability scanning, and secret detection. Shared environments should use an encrypted remote state backend with locking, short-lived GitHub Actions OIDC credentials, separate AWS accounts or roles per environment, and required pull-request approvals.

## Cost and production boundary

NAT gateways, VPC endpoints, flow-log delivery, GuardDuty, Security Hub, Config, and the sample application can incur AWS charges. They are opt-in where practical. This repository is a portfolio demonstration and requires organization-specific controls, alerting, backups, and incident-response procedures before production use.
