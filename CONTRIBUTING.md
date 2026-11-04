# Contributing

1. Create a branch for each change.
2. Run `terraform fmt -recursive` and `terraform validate` from `Terra-HCL`.
3. Run the security scanners used by `.github/workflows/terraform-security.yml`.
4. Explain security impact, cost impact, and rollback behavior in the pull request.
5. Never commit credentials, private keys, Terraform state, or generated plans.

Changes to IAM, network boundaries, encryption, or public exposure require explicit review.
