# CloudGate delivery roadmap

## Delivered: secure foundation

- Multi-AZ VPC with public and private subnets
- Internet and NAT routing
- SSM-managed administrative instance with no public SSH ingress
- IMDSv2 and encrypted EBS
- Least-privilege ALB, application, and database security-group paths
- Optional CloudTrail, VPC Flow Logs, GuardDuty, Security Hub, AWS Config, and private SSM endpoints

## Delivered: DevSecOps controls

- Terraform formatting and validation
- TFLint
- Checkov and Trivy IaC scanning
- Gitleaks secret detection
- Dependabot for GitHub Actions
- CODEOWNERS and contribution/security policies

## Next production-hardening steps

1. Use separate AWS accounts or deployment roles for each environment.
2. Store Terraform state in a versioned, encrypted S3 backend with locking.
3. Configure GitHub Actions OIDC and prohibit long-lived AWS credentials.
4. Add centralized alert routing, CloudTrail organization trails, backups, and tested recovery procedures.
5. Add HTTPS with ACM, WAF, and Route 53 when exposing a real application.
6. Add policy-as-code approval for IAM and public network changes.

The optional sample application and database are deliberately small demonstrations of secure traffic paths, not a production workload.
