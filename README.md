# Enterprise AWS Landing Zone for HIPAA-aligned Workloads

This repository contains a Terraform landing-zone scaffold for:
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
- sandbox: 10.80.0.0/16

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

## Security foundation

The security environment configures AWS Config, GuardDuty, Security Hub, a
Config bucket, and KMS. SCP policy documents are present, but they are not yet
created or attached by Terraform. CloudTrail organization trails, centralized
log-archive delivery, cross-account Config aggregation, Identity Center group
provisioning, and cross-account private DNS associations remain deployment
prerequisites or follow-up work.

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

## Deployment workflow

Run the bootstrap stack once from the management account. It owns AWS
Organizations, accounts, OUs, and the remote state backend. The management
environment manages IAM Identity Center and does not create a second
Organization.

Create an ignored `terraform.tfvars` file in each environment directory. Set
`expected_account_id` and `terraform_role_arn`, plus that environment's required
inputs. Supply passwords through a secure secret process; do not commit them.
The `terraform.tfvars.example` files are templates; replace every placeholder
before use. For passwords, prefer `TF_VAR_db_password` and
`TF_VAR_ad_password` from a secrets-backed deployment environment.

Deploy one environment with `scripts/deploy-environment.sh <environment>`. The
script initializes using that environment's `backend.hcl`, validates, displays
a saved plan, and applies only after you type `APPLY <environment>`. Running
`scripts/deploy-all.sh` invokes the same gated process in this order:
management, security, network, shared-services, sandbox, workload-dev,
workload-stage, workload-prod. It will stop if an environment is not configured
or an approval is declined.

After bootstrap, apply `network` first. Configure `transit_gateway_spoke_account_ids`
with the exact spoke account IDs. Then put the network stack's TGW output into
each spoke's `transit_gateway_id`; the deployment script does not discover or
trust cross-account outputs automatically. Set only explicitly approved CIDRs
in each `transit_route_cidrs`. AWS RAM shares the TGW within the Organization;
spoke roots create their own attachments and routes. Test DNS, route tables,
security groups, and return paths before sending application traffic.

Copy the `state_bucket_name` and `lock_table_name` bootstrap outputs into every
environment's `backend.hcl` (the bucket and lock table must match bootstrap;
each `key` must remain unique). This keeps clean checkouts and CI independent of
local `.terraform` metadata.

The example Transit Gateway uses its default route table. It does not provide
firewall inspection or on-premises VPN connectivity; add and test those routing
paths before claiming centralized inspection or hybrid connectivity.

IAM Identity Center must be enabled in the management account before applying
the management environment. Create the referenced groups first. The current
spoke attachments provide private routing through the TGW; they do not force
traffic through an inspection appliance.

## Important

This repository is production-standard scaffolding. Before deployment, replace
all placeholder account IDs, CIDRs, subnets, IAM role ARNs, and service inputs
with values approved for the target organization. Review every saved plan;
validation alone does not establish production readiness.
