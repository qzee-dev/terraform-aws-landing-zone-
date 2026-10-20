# Enterprise AWS Landing Zone for HIPAA-aligned Workloads

This repository contains a modular AWS Landing Zone blueprint built for:
- AWS Organizations
- multi-account structure
- centralized security and logging
- hub-and-spoke network design
- hybrid connectivity
- production workload isolation
- staging and development isolation
- sandbox controls
- strict tagging and cost governance
- multi-state Terraform architecture to reduce blast radius

## Account model

- Management Account
- Log Archive Account
- Security Tooling Account
- Network Account
- Shared-System Account
- Production Account
- Staging Account
- Development Account
- Sandbox Account

## OU model

- Security-OU
- Infrastructure-OU
- Workloads-Prod-OU
- Workloads-NonProd-OU
- Sandbox-OU

## State model

State is separated by environment/layer to reduce blast radius:
- management
- security
- network
- shared-services
- workload-prod
- workload-stage
- workload-dev
- sandbox

## Tagging standard

All resources must include:
- Environment
- ProjectID
- Owner
- CostCenter
- Compliance
- Automation

## Security controls

- SCP baseline
- OU-specific SCPs
- Central logging and guardrails
- Private networking only
- No public database access
- KMS encryption
- VPC Flow Logs
- AWS Config
- CloudTrail
- GuardDuty
- Security Hub
- Macie
- IAM Identity Center
- Centralized DNS and AD

## Important

This is a production-ready skeleton. Adjust CIDRs, account IDs, and naming to your organization.
