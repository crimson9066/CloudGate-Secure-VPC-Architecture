# CloudGate Secure VPC Architecture

A production-ready AWS VPC architecture with secure networking, NAT Gateway, and SSH Bastion host built with Terraform.

##  Architecture Overview

This Terraform configuration creates a secure, scalable VPC infrastructure with:

- **VPC**: 10.0.0.0/16 CIDR block with DNS support
- **Multi-AZ Setup**: Resources distributed across 3 availability zones for high availability
- **Public Subnets**: 3 subnets (10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24) with internet access via IGW
- **Private Subnets**: 3 subnets (10.0.3.0/24, 10.0.4.0/24, 10.0.5.0/24) with internet access via NAT Gateway
- **NAT Gateway**: Single NAT Gateway in first public subnet for cost optimization
- **SSH Bastion Host**: Hardened Amazon Linux 2 instance for secure access to private resources
- **Security Groups**: Least-privilege access controls

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                        │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                    Internet Gateway                         │  │
│  └──────────────────────────┬─────────────────────────────────┘  │
│                             │                                     │
│  ┌──────────────────────────┴─────────────────────────────────┐  │
│  │              Public Subnets (3 AZs)                         │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐            │  │
│  │  │  10.0.0/24 │  │  10.0.1/24 │  │  10.0.2/24 │            │  │
│  │  │            │  │            │  │            │            │  │
│  │  │  Bastion   │  │            │  │            │            │  │
│  │  │   Host     │  │            │  │            │            │  │
│  │  │            │  │            │  │            │            │  │
│  │  │  NAT GW────┼──┼────────────┼──┼────────────┘            │  │
│  │  └────────────┘  └────────────┘  └────────────┘            │  │
│  └──────────────────────────┬─────────────────────────────────┘  │
│                             │                                     │
│  ┌──────────────────────────┴─────────────────────────────────┐  │
│  │             Private Subnets (3 AZs)                         │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐            │  │
│  │  │  10.0.3/24 │  │  10.0.4/24 │  │  10.0.5/24 │            │  │
│  │  │            │  │            │  │            │            │  │
│  │  │  App/DB    │  │  App/DB    │  │  App/DB    │            │  │
│  │  │ Instances  │  │ Instances  │  │ Instances  │            │  │
│  │  └────────────┘  └────────────┘  └────────────┘            │  │
│  └────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

##  Prerequisites

1. **Terraform**: Version >= 1.0
   ```bash
   terraform version
   ```

2. **AWS CLI**: Configured with credentials
   ```bash
   aws configure
   ```

3. **AWS Account**: With appropriate permissions (EC2, VPC, IAM)

4. **SSH Key Pair**: For bastion host access
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/cloudgate-bastion
   ```

##  Quick Start

### 1. Configure Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:

- **bastion_public_key**: Paste your SSH public key (from `~/.ssh/cloudgate-bastion.pub`)
- **allowed_ssh_cidr_blocks**: Your IP address (get it with `curl ifconfig.me`)

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 5. Get Outputs

```bash
terraform output
```

##  Accessing the Bastion Host

After deployment, connect to your bastion host:

```bash
# Using the output command
terraform output bastion_ssh_command

# Or manually
ssh -i ~/.ssh/cloudgate-bastion ec2-user@<BASTION_PUBLIC_IP>
```

##  Security Best Practices

###  Implemented

-  **Least Privilege Access**: Security groups restrict access to minimum required
-  **SSH Key Authentication**: Password authentication disabled
-  **Encrypted Storage**: EBS volumes encrypted at rest
-  **IMDSv2**: Instance metadata service v2 required
-  **Private Subnets**: Backend resources isolated from direct internet access
-  **NAT Gateway**: Secure outbound internet access for private instances
-  **Multi-AZ**: High availability across availability zones

###  Required Actions

1. **Restrict SSH Access**: Update `allowed_ssh_cidr_blocks` in `terraform.tfvars` to your IP
   ```hcl
   allowed_ssh_cidr_blocks = ["YOUR.IP.ADDRESS/32"]
   ```

2. **Enable AWS CloudWatch**: Monitor bastion host access
3. **Enable VPC Flow Logs**: Track network traffic
4. **Set up AWS GuardDuty**: Threat detection
5. **Enable AWS Config**: Compliance monitoring

##📊 Resource Summary

| Resource | Count | Purpose |
|----------|-------|---------|
| VPC | 1 | Network isolation |
| Public Subnets | 3 | Internet-facing resources |
| Private Subnets | 3 | Backend resources |
| Internet Gateway | 1 | Public internet access |
| NAT Gateway | 1 | Private subnet internet access |
| Elastic IPs | 2 | NAT Gateway + Bastion |
| Security Groups | 2 | Access control |
| EC2 Instance | 1 | Bastion host |
| Route Tables | 2 | Traffic routing |

##  Cost Estimation

Approximate monthly costs in me-south-1 (Bahrain):

- **NAT Gateway**: ~$33/month (+ data processing)
- **Bastion t3.micro**: ~$8/month
- **Elastic IPs**: $0 (while attached)
- **Data Transfer**: Variable

**Total**: ~$41/month (excluding data transfer)

##  Customization

### Change Region

Edit `terraform.tfvars`:
```hcl
aws_region = "eu-central-1"
availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
```

### Change Instance Type

Edit `terraform.tfvars`:
```hcl
bastion_instance_type = "t3.small"
```

### Disable Bastion EIP

Edit `terraform.tfvars`:
```hcl
assign_eip_to_bastion = false
```

##  File Structure

```
Terraform/
├── main.tf                     # Provider configuration
├── vpc.tf                      # VPC, subnets, routing
├── security_groups.tf          # Security group rules
├── bastion.tf                  # Bastion host configuration
├── variables.tf                # Variable definitions
├── outputs.tf                  # Output values
├── terraform.tfvars.example    # Example configuration
└── README.md                   # This file
```

##  Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

##  Next Steps

1. **Add Private Instances**: Deploy application servers in private subnets
2. **Set up RDS**: Deploy database in private subnets
3. **Add Load Balancer**: ALB in public subnets
4. **Enable Monitoring**: CloudWatch, VPC Flow Logs
5. **Add Auto Scaling**: For application tier
6. **Implement WAF**: Web application firewall
7. **Set up Backup**: AWS Backup for resources

##  Troubleshooting

### Cannot connect to bastion

1. Check security group allows your IP:
   ```bash
   aws ec2 describe-security-groups --group-ids <SG_ID>
   ```

2. Verify instance is running:
   ```bash
   aws ec2 describe-instances --instance-ids <INSTANCE_ID>
   ```

3. Check SSH key permissions:
   ```bash
   chmod 400 ~/.ssh/cloudgate-bastion
   ```

### Terraform apply fails

1. Check AWS credentials:
   ```bash
   aws sts get-caller-identity
   ```

2. Verify region availability:
   ```bash
   aws ec2 describe-availability-zones --region me-south-1
   ```

##  Additional Resources

- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

##  License

This project is provided as-is for educational and development purposes.

---

**Region**: me-south-1 (Bahrain) - Optimized for Egypt  
**Maintained by**: CloudGate Team  
**Last Updated**: January 2026
