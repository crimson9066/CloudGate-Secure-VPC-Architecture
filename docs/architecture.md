# CloudGate architecture

## Intent

CloudGate is a secure AWS network foundation delivered as Terraform. It demonstrates segmentation, identity-based administration, least-privilege traffic paths, and automated IaC security checks.

```mermaid
flowchart TB
    Internet((Internet)) --> ALB[Optional public ALB]
    ALB --> App[Private subnet Auto Scaling group]
    App --> NAT[NAT Gateway]
    Bastion[SSM-managed admin instance] --> SSM[AWS Systems Manager]
    NAT --> Internet
    VPC[VPC: 10.0.0.0/16] --> Public[Public subnets across AZs]
    VPC --> Private[Private subnets across AZs]
    Public --> ALB
    Public --> Bastion
    Private --> App
```

## Trust boundaries

- The internet can reach only the optional load balancer.
- Application instances have no public IP addresses.
- Administrative access is through IAM-authenticated Session Manager.
- Security groups reference trusted security groups rather than broad internal CIDRs.
- Optional security services provide network visibility and account-level detection.

The sample application is intentionally small. It demonstrates a secure request path; it is not intended to represent a complete production workload.
