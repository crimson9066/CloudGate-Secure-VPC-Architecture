# CloudGate Secure VPC Architecture

A production-grade AWS network infrastructure implementation using Terraform. This project demonstrates cloud architecture best practices with a focus on security, scalability, and maintainability.

## Overview

This repository contains Infrastructure as Code (IaC) for deploying a secure Virtual Private Cloud on AWS. The architecture follows AWS Well-Architected Framework principles and implements a common pattern used in production environments: isolated public/private subnets, managed NAT gateway, and secure bastion host access.

The infrastructure is designed for the Middle East (Bahrain) region but can be adapted to any AWS region with minimal configuration changes.

## Architecture

The network design includes:

- **VPC**: 10.0.0.0/16 CIDR with DNS resolution enabled
- **Multi-AZ deployment**: Resources distributed across three availability zones for fault tolerance
- **Public subnets**: Three /24 subnets for internet-facing resources (ALB, bastion, NAT gateway)
- **Private subnets**: Three /24 subnets for application and database tiers
- **Internet Gateway**: Direct internet access for public subnet resources
- **NAT Gateway**: Managed outbound internet access for private subnet resources
- **Bastion host**: Hardened Amazon Linux 2 instance for secure SSH access to private resources
- **Security groups**: Least-privilege access controls with configurable IP restrictions

## Technical Implementation

**Infrastructure as Code**: Terraform (HCL)  
**Cloud Provider**: AWS  
**Default Region**: me-south-1 (Bahrain)  
**State Management**: Local state (easily adaptable to remote backend)

### Key Features

- Modular Terraform configuration with separated concerns (networking, security, compute)
- Automated bastion host hardening through user data scripts
- IMDSv2 enforcement for enhanced instance metadata security
- Encrypted EBS volumes
- Parameterized configuration through variables and tfvars
- Comprehensive outputs for integration with other infrastructure components

### Security Controls

The implementation includes several security measures:

- SSH key-based authentication only (password auth disabled)
- Configurable source IP restrictions for SSH access
- Network segmentation through public/private subnet isolation
- Security group rules following least-privilege principle
- Encrypted storage for bastion host
- Automatic security updates on bastion instance

## Repository Structure

```
├── Terraform/
│   ├── main.tf                     # Provider and backend configuration
│   ├── vpc.tf                      # VPC, subnets, routing tables
│   ├── security_groups.tf          # Security group definitions
│   ├── bastion.tf                  # Bastion host configuration
│   ├── variables.tf                # Input variable definitions
│   ├── outputs.tf                  # Output value definitions
│   ├── terraform.tfvars.example    # Example configuration
│   └── README.md                   # Deployment documentation
├── cdk-python/                     # Future: CDK implementation
├── PHASES.md                       # Project roadmap and development phases
└── README.md                       # This file
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- SSH key pair for bastion host access
- AWS account with permissions for VPC, EC2, and related services

## Deployment

Detailed deployment instructions are available in the [Terraform README](Terraform/README.md).

Quick start:

```bash
cd Terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
terraform init
terraform plan
terraform apply
```

## Configuration

The infrastructure is highly configurable through variables. Key parameters include:

- AWS region and availability zones
- VPC and subnet CIDR blocks
- Bastion instance type and SSH key
- IP whitelist for SSH access
- Environment tags (dev, staging, production)

See [variables.tf](Terraform/variables.tf) for the complete list of configurable parameters.

## Cost Considerations

Approximate monthly cost in me-south-1 region:

- NAT Gateway: ~$33/month (plus data processing fees)
- Bastion host (t3.micro): ~$8/month
- Elastic IPs: No charge when attached
- Data transfer: Variable based on usage

Total baseline cost is roughly $40-50/month excluding data transfer. For development environments, costs can be reduced by stopping the bastion host when not in use.

## Project Status

This project is currently in Phase 1 (Foundation Infrastructure). The network layer is complete and functional. See [PHASES.md](PHASES.md) for the development roadmap and planned features.

### Current Capabilities

- Fully functional multi-AZ VPC with public/private subnet isolation
- Secure SSH access through hardened bastion host
- Internet connectivity for both public resources (direct) and private resources (via NAT)
- Production-ready network foundation

### Planned Enhancements

- Application tier deployment (EC2/ECS)
- Database layer (RDS Multi-AZ)
- Load balancing and auto-scaling
- Comprehensive monitoring and logging (VPC Flow Logs, CloudWatch, GuardDuty)
- CI/CD pipeline integration
- Multi-region deployment capabilities

## Use Cases

This infrastructure serves as a foundation for:

- Web applications requiring secure database access
- Multi-tier applications with clear network separation
- Development/staging environments that mirror production architecture
- Learning and demonstrating cloud architecture best practices
- Starting point for more complex AWS deployments

## Skills Demonstrated

- Infrastructure as Code using Terraform
- AWS networking concepts (VPC, subnets, routing, NAT)
- Cloud security best practices
- Multi-AZ architecture for high availability
- Parameterized and reusable IaC modules
- Documentation and project organization

## Future Development

The project roadmap includes:

- Converting infrastructure to AWS CDK (Python) for comparison
- Implementing application and database tiers
- Adding comprehensive monitoring and alerting
- Setting up automated backups and disaster recovery
- Implementing CI/CD pipelines
- Multi-region deployment with failover capabilities

See [PHASES.md](PHASES.md) for detailed information on each development phase.

## License

This project is available for educational and portfolio purposes.

## Contact

This project was developed to demonstrate cloud infrastructure skills and AWS best practices. Feel free to review the code and infrastructure design.

---

**Note**: This is a demonstration project. The configuration includes placeholder values that should be customized before production use, particularly security-related settings like SSH IP restrictions and key pairs.
