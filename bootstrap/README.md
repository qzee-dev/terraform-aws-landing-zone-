# Enterprise AWS Landing Zone for HIPAA-aligned Workloads

This repository contains a production-standard Terraform landing zone scaffold for:
- AWS Organizations
- multi-account design
- centralized security and logging
- hub-and-spoke network architecture
- hybrid connectivity
- production workload isolation
- staging and development isolation
- sandbox controls
- cost governance and tagging
- multi-state remote-state pattern

## Architecture

This repo models:

- AWS Organizations root
- Security-OU
- Infrastructure-OU
- Workloads-Prod-OU
- Workloads-NonProd-OU
- Sandbox-OU

Accounts:

- Management Account
- Log Archive Account
- Security Tooling Account
- Network Account
- Shared-System Account
- Production Account
- Staging Account
- Development Account
- Sandbox Account

VPCs:

- inspection: 10.30.0.0/16
- shared-services: 10.40.0.0/16
- prod: 10.50.0.0/16
- stage: 10.60.0.0/16
- dev: 10.70.0.0/16

## State model

Remote state is isolated per environment:
- management
- security
- network
- shared-services
- workload-prod
- workload-stage
- workload-dev
- sandbox

## Security controls

- AWS Organizations with SCPs
- centralized AWS Config
- centralized CloudTrail
- GuardDuty
- Security Hub
- KMS encryption
- VPC flow logs
- restricted public access
- centralized DNS and AD
- private-only networking principles

## Tagging standard

All resources should include:
- Environment
- ProjectID
- Owner
- CostCenter
- Compliance
- Automation

## Secret handling

Do not store secrets in Git.
Use:
- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- CI/CD secret stores

## Important

This repository is production-standard scaffolding. Before deployment, replace all placeholder values with real AWS account IDs, real subnets, real CIDRs, real KMS IDs, and secure secrets.
