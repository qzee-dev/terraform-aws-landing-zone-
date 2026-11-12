# Self-Managed AWS Organizations Landing Zone Runbook

This is the canonical operating guide for this repository. It uses AWS
Organizations and IAM Identity Center; **AWS Control Tower is out of scope**.
The repository is a Terraform scaffold, not a production-ready landing zone.
Complete the production gates in this runbook before moving production
workloads or applying restrictive policies.

## 1. Placeholders and decisions

Every `<UPPERCASE_PLACEHOLDER>` is unavailable organization-specific data.
Replace it only in local ignored `terraform.tfvars` files or approved secret
stores. Never commit real account identifiers, emails, role ARNs, network
ranges, credentials, or SCIM tokens. Values like `10.30.0.0/16` in this
runbook are illustrative examples, not approved network allocations.

Collect these before deployment:

| Placeholder | Meaning |
|---|---|
| `<MANAGEMENT_ACCOUNT_ID>` | Existing 12-digit AWS management account ID |
| `<AWS_REGION>` | AWS home/deployment Region; Identity Center and direct AD source must use the same Region |
| `<ACCOUNT_EMAIL_ALIAS>` | Unique, controlled root email address for each new AWS account |
| `<STATE_BUCKET_NAME>` | Globally unique bootstrap S3 state bucket name |
| `<STATE_BUCKET_PREFIX>` | Unique lowercase prefix for nine environment state buckets |
| `<LOG_BUCKET_PREFIX>` | Unique lowercase prefix for the CloudTrail log bucket |
| `<ORGANIZATION_ID>` | AWS Organizations ID output by bootstrap |
| `<ORGANIZATION_ROOT_ID>` | Organizations root ID output by bootstrap; Security Hub policy target |
| `<APPROVED_LOG_RETENTION_DAYS>` | Integer CloudTrail and S3 access-log retention period approved by legal/audit (90+ days); leave at `0` for no lifecycle expiry until approved |
| `<DEPLOYER_ROLE_ARN_ENV>` | Existing, unique source IAM role ARN trusted by the state backend for one environment |
| `<TERRAFORM_EXECUTION_ROLE_ARN_ENV>` | Role Terraform assumes in the target account to manage its infrastructure |
| `<IDENTITY_CENTER_GROUP_ID_...>` | Existing group IDs provisioned into this Identity Center instance |
| `<MEMBER_ACCOUNT_ID_...>` | Actual account IDs, from bootstrap outputs or the existing-account inventory |
| `<VPC_CIDR_...>` / `<APPROVED_ROUTE_CIDR_...>` | Non-overlapping ranges approved by the network owner |
| `<TRANSIT_GATEWAY_ID>` | TGW output after the network environment is deployed |
| `<PRIVATE_DNS_ZONE_NAME>` | Approved private DNS domain |
| `<SECRET_FROM_APPROVED_STORE>` | Secret injected at deployment time, never committed to Terraform files |
| `<EXISTING_ACCOUNT_ID>` / `<HANDSHAKE_ID>` | Existing account and invitation handshake values during adoption |

Use the actual values in local copies of the `.tfvars.example` files. Bootstrap
validates several placeholders, but that is not a substitute for review.

## 2. What the repository does and does not do

### Included scaffold

- Bootstrap Terraform creates an AWS Organization with all features, five OUs,
  eight new member accounts, bootstrap state storage, and nine isolated
  environment state backends.
- Nine roots manage Identity Center assignments, security services, network
  hub, shared services, and workload examples.
- The Log Archive root creates the encrypted, private CloudTrail destination;
  S3 server-access logging, and the management root creates a multi-Region
  organization trail. Expiration is configurable and disabled by default.
- GuardDuty and Security Hub use the Security account as delegated admin.
  Config recorders are enabled in each account root, with an organization
  aggregator in Security.
- Bootstrap attaches a conservative baseline SCP to the five member-account
  OUs. It blocks leaving the Organization and root access-key creation.
- The network root creates a multi-AZ Network Firewall, Flow and Alert logs,
  an inspection VPC NACL, and separate TGW route tables for spoke-to-inspection
  and inspection-to-spoke traffic.
- Security creates an SNS topic and EventBridge rules for high-severity
  GuardDuty and active HIGH/CRITICAL Security Hub findings. Email delivery is
  optional and requires subscription confirmation.
- A guarded bootstrap/deployment script shows a saved plan and requires
  interactive approval before apply.
- Example SCP JSON files and account/VPC structures are provided.

### Not complete; do not assume production protection

- Bootstrap does **not** create the management account. It is only for a new
  Organization in an existing, dedicated management account. Do not run it
  against an existing Organization.
- Identity Center must already be enabled and connected to one identity source.
  Terraform creates permission sets and selected group-to-account assignments;
  it does not configure Entra SAML/SCIM, create IdP users/groups, or sync AD.
- The Shared Services AD module creates AWS Managed Microsoft AD for workloads.
  It does not configure Identity Center federation or automatically provide
  user/group synchronization.
- Only the conservative baseline SCP is attached, to the five member-account
  OUs. The management account is outside SCP scope. Other sample SCPs are
  unattached; review, validate, and stage any added policy. See
  [SCP controls](#9-scps-and-guardrails).
- GuardDuty enrollment and each AWS Config recorder are configured in the
  selected `aws_region`. `all_regions` on the Config aggregator does not create
  recorders in other Regions. GuardDuty administration must be repeated in
  every enabled Region. Security Hub uses central configuration with all
  supported Regions linked from its home Region.
- The included GuardDuty baseline does not opt in to S3 data events, EKS audit
  logs, or malware scanning. Assess their coverage and service costs separately.
- Existing accounts may already have trails, Config recorders, detectors, or
  Security Hub enabled. Inventory and import/reconcile those resources before
  applying this configuration; do not create duplicate service resources.
- CloudTrail delivery is centralized and encrypted. S3 access logging and
  high-severity finding notifications are configured. Lifecycle expiration is
  disabled until `<APPROVED_LOG_RETENTION_DAYS>` is approved; restore drills
  and recipient subscription confirmation remain operational tasks.
- Security Hub standards, GuardDuty, AWS Config recording, CloudTrail storage,
  and KMS incur usage charges. Estimate cost and assign budget alerts before
  enabling this baseline broadly.
- Network Firewall inspects east-west TGW traffic only after spoke attachment
  IDs and approved routes/CIDRs are supplied and the network root is reapplied.
  Its allowlist is empty by default, so traffic is denied until reviewed
  Suricata rules are supplied. Centralized internet egress/NAT and VPN/Direct
  Connect are not implemented.
- Workload networking is illustrative. Private/public subnet tiers, endpoints,
  centralized DNS associations, and production routes need review and
  completion.
- State buckets, keys, and roles are in the management account. Per-environment
  roles reduce routine state access but do not protect from management-account
  administrators. A separate state account is a stronger boundary and is not
  implemented.
- Terraform state can contain secrets even when Terraform marks values
  `sensitive`. Restrict state access and inject secrets through a vault or
  approved CI/CD secret mechanism.
- HIPAA tags and sample policies are not evidence of compliance. Validate
  service eligibility, BAA coverage, control operation, and audit requirements.

## 3. AWS account, root, IAM, and sign-in

| Term | Meaning |
|---|---|
| AWS account | A security, billing, and resource boundary with a 12-digit account ID |
| Account root user | One powerful sign-in identity for each AWS account, using its root email/password; secure with MFA and do not create access keys |
| Organizations root | The top node of an Organization's OU tree; it is not an account or a user |
| Management account | The existing account that owns Organizations and consolidated billing; keep workloads out of it |
| IAM | Per-account permissions, users, and roles; there is no special “IAM account” type |
| IAM Identity Center | Organization-level workforce federation. Users select an assigned account and permission set and receive temporary credentials |

An account ID identifies the AWS account. It is not a user name or password.
Root signs in with its account root email/password. An IAM user (discouraged
for humans) signs in with account ID/alias plus username. An Identity Center
user signs in at the organization's access portal. An automation role uses
short-term assumed-role credentials.

If an existing account runs critical IAM-backed jobs, it remains an ordinary
member account when onboarded. Joining Organizations does not merge accounts
or move workloads. Do not make it the management account merely because it
contains IAM resources. Keep root accounts protected during onboarding and
test each account's replacement access before changing credentials.

## 4. Choose one workforce identity source

Use **IAM Identity Center** for AWS console and CLI access, and use one
authoritative workforce identity source per Organization:

| Current workforce source | AWS connection | Guidance |
|---|---|---|
| Microsoft Entra ID | External SAML IdP plus SCIM provisioning to Identity Center | Preferred when Entra already owns workforce lifecycle; require MFA/conditional access in Entra |
| On-premises Active Directory | AD Connector or AWS Managed Microsoft AD as the Identity Center source | Directory must be in the Organization management account or Identity Center delegated-admin account, and the same Region as Identity Center |
| No directory | Select one source before creating users | Entra is a common Microsoft workforce choice; create Managed Microsoft AD only if workloads require AD |

Do not configure Entra and AD as competing identity sources. Identity Center
supports one identity source per Organization. Changing an already-used
identity source requires a migration/reassignment plan.

### Entra SAML/SCIM sequence

1. Enable IAM Identity Center in the management account in `<AWS_REGION>`.
2. Configure Entra as the external SAML provider using the service-provider
   metadata from Identity Center and the federation metadata from Entra.
3. Configure the Entra AWS IAM Identity Center enterprise application for SAML
   sign-in. Require MFA and the organization's conditional-access policies.
4. Enable SCIM provisioning in Identity Center. Configure Entra automatic
   provisioning with the SCIM endpoint and token. Store the token in
   `<APPROVED_SECRET_STORE>` and never in Terraform, shell history, or Git.
5. Scope provisioning to approved groups. Pilot synchronization and verify
   users, groups, and memberships appear in Identity Center.
6. Record synchronized group IDs in the management environment's local
   `terraform.tfvars`. Apply the management environment and verify assignments
   before announcing AWS access.

### Active Directory sequence and important placement limitation

This repository's implemented AD path uses the Shared Services account for
both AWS Managed Microsoft AD and the IAM Identity Center delegated
administrator. AWS allows the directly connected directory to be in the
management account or Identity Center delegated-administrator account. It
must be in the same Region as Identity Center.

1. Enable IAM Identity Center in `<AWS_REGION>` from the Organizations
   management account. Do this before applying the management Terraform root.
2. Set `identity_center_delegated_admin_account_id` in
   `environments/management/terraform.tfvars` to
   `<SHARED_SERVICES_ACCOUNT_ID>`. Keep the group IDs empty on this first
   management apply. The Terraform registers the Shared Services account as
   the `sso.amazonaws.com` delegated administrator and creates permission sets;
   empty group IDs intentionally create no account assignments yet. The
   management Terraform role must be authorized to register that Organizations
   delegated administrator.
3. Deploy `network`, then `shared-services`. In
   `environments/shared-services/terraform.tfvars`, set
   `ad_directory_name = "<AD_DNS_DOMAIN_NAME>"`, a private DNS zone as needed,
   and inject `ad_password` from the approved secret store. Confirm the domain
   name and DNS plan with the directory owner. The AD module uses two private
   subnets in separate Availability Zones. Directory creation incurs AWS
   charges.
4. Read the resulting Directory Service ID:

   ```sh
   terraform -chdir=environments/shared-services output -raw active_directory_id
   ```

5. In the AWS console, sign in as an authorized IAM Identity Center
   administrator, switch to `<AWS_REGION>`, then go to **IAM Identity Center >
   Settings > Identity source > Actions > Change identity source**. Select
   **Active Directory**, select the directory whose ID is
   `<SHARED_SERVICES_DIRECTORY_ID>`, choose **Next**, review, type `ACCEPT`,
   then choose **Change identity source**. Changing an existing source can
   disrupt access; inventory and plan existing assignments/users first.
6. In Identity Center **Settings > Identity source > Actions > Manage Sync**,
   synchronize the required initial admin user and approved role groups.
   Wait until they appear in **Users** and **Groups**. AD passwords are not
   copied to Identity Center.
7. Retrieve group IDs from the Identity Center console or CLI:

   ```sh
   aws sso-admin list-instances --region "<AWS_REGION>"
   aws identitystore list-groups \
     --identity-store-id "<IDENTITY_STORE_ID>" \
     --region "<AWS_REGION>" \
     --query 'Groups[].{Group:DisplayName,Id:GroupId}' \
     --output table
   ```

8. Fill the five group IDs in management `terraform.tfvars`, then reapply:

   ```sh
   AWS_PROFILE="<MANAGEMENT_DEPLOYER_PROFILE>" \
     scripts/deploy-environment.sh management
   ```

   The management Terraform then assigns SecurityAudit to Security Tooling,
   NetworkAdmin to Network, Developer to Development, and ReadOnly to Staging
   and Production. Verify each assignment and test with a non-admin user.
9. Users open the IAM Identity Center access portal, sign in with their AD
   credentials and the organization's supported MFA flow, and choose the
   assigned account and permission set. Verify MFA support for the chosen AD
   connection rather than assuming it is enabled. For AWS CLI, run
   `aws configure sso --profile "<PROFILE_NAME>"` and complete the browser
   sign-in.

The management Terraform registration is the AWS Organizations delegation;
the Identity Center source switch is an AWS-console step and is not exposed as
a supported Terraform resource here. The Shared Services directory is now
eligible as the source only after the delegated administrator registration
succeeds. It is not automatically federated merely by creating the directory.

### Provisioned access in this repository

The management root expects synchronized groups and account IDs. Its default
assignments are:

| Group placeholder / example group | Permission set | AWS account |
|---|---|---|
| `<IDENTITY_CENTER_SECURITY_AUDIT_GROUP_ID>` | `SecurityAudit` (`SecurityAudit` AWS managed policy; read-only) | `<SECURITY_TOOLING_ACCOUNT_ID>` |
| `<IDENTITY_CENTER_NETWORK_GROUP_ID>` | `NetworkAdmin` (`AmazonVPCFullAccess`; broad, review before use) | `<NETWORK_ACCOUNT_ID>` |
| `<IDENTITY_CENTER_DEVELOPER_GROUP_ID>` | `Developer` (`PowerUserAccess`; broad, use in development only) | `<DEVELOPMENT_ACCOUNT_ID>` |
| `<IDENTITY_CENTER_STAGE_READONLY_GROUP_ID>` | `ReadOnly` | `<STAGING_ACCOUNT_ID>` |
| `<IDENTITY_CENTER_PROD_READONLY_GROUP_ID>` | `ReadOnly` | `<PRODUCTION_ACCOUNT_ID>` |
| Optional `<IDENTITY_CENTER_PLATFORM_ADMIN_GROUP_ID>` | `AWSAdministratorAccess`, 1-hour session | Management account only; Terraform assignment is disabled when the input is empty |

Review broad managed policies and replace with tailored least-privilege
permissions before production use. Production write access is not provisioned
here; prefer CI/CD roles with approvals and short sessions. Never make a human
group a shared root user.

### Joiner, mover, leaver

1. HR/identity administrators manage the user and group membership in the
   source directory/IdP.
2. Verify provisioning, then grant only approved group-to-account permission
   set assignments. Record approver and ticket.
3. For role changes, remove old memberships and check for stale direct
   assignments.
4. On departure, disable the source identity, revoke sessions where possible,
   remove access, and rotate any credentials/secrets the person could reach.
5. Review privileged membership and account assignments at least quarterly.

## 5. New Organization: greenfield rollout

### Before Terraform

1. Decide whether this is truly a new Organization. If an Organization already
   exists, use its management account and do not run this bootstrap.
2. Create/designate a dedicated management account with controlled root email,
   MFA, alternate contacts, billing owner, and no routine workloads.
3. Secure its root user (unique password, MFA, no access keys). Create and test
   independently controlled break-glass access.
4. Select `<AWS_REGION>` and the AWS partition. Commercial, China, and GovCloud
   accounts cannot be mixed in one Organization.
5. Inventory workloads, compliance needs, account owners, service quotas,
   Region constraints, CIDRs, DNS, on-premises routes, and account email aliases.
6. Define unique controlled email aliases for each new member account. Define
   one existing, unique source role for each environment's state backend.
7. Install Terraform `>= 1.10`, AWS CLI, and `jq`; configure MFA-protected
   bootstrap credentials. Confirm the current identity is in
   `<MANAGEMENT_ACCOUNT_ID>`. The management Terraform execution role also
   needs reviewed Organizations delegation permissions and the IAM Identity
   Center administration permissions required by its plan.

### Configure and run bootstrap

1. Copy the example:

   ```sh
   cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
   ```

2. Replace all placeholders with real local values. At minimum configure:
   `<MANAGEMENT_ACCOUNT_ID>`, eight unique account emails, `<STATE_BUCKET_NAME>`,
   `<STATE_BUCKET_PREFIX>`, and nine **different existing** source-role ARNs.
   Each source role must be allowed to assume only its intended state role.
   Do not use the management provider role as a state role unless that trust is
   explicitly approved.
3. Review the bootstrap Terraform and confirm no Organization already exists
   in this management account. Bootstrap creates the Organization, OUs,
   accounts, buckets, KMS keys, state roles, and bootstrap lock table.
4. Run the guarded script:

   ```sh
   scripts/bootstrap-state.sh
   ```

   It validates, creates and displays a plan, then requires typing
   `APPLY BOOTSTRAP`. It applies the bootstrap, migrates its state into the
   dedicated S3 bucket, and generates the nine environment backend files.
   Do not approve a plan that shows unexpected Organization/account creation.
5. Capture output IDs in `<APPROVED_SECRET_STORE>` or another controlled
   inventory. Do not commit generated outputs or IDs.

**Never use `scripts/bootstrap-state.sh` for an existing Organization.** This
repo does not import/adopt accounts via that script.

To inspect bootstrap outputs later:

```sh
terraform -chdir=bootstrap output -raw management_account_id
terraform -chdir=bootstrap output -raw security_tooling_account_id
terraform -chdir=bootstrap output -raw network_account_id
terraform -chdir=bootstrap output -raw development_account_id
terraform -chdir=bootstrap output -raw staging_account_id
terraform -chdir=bootstrap output -raw production_account_id
```

Use the corresponding named outputs for log archive, shared services, sandbox,
OU IDs, and backend settings. Treat `terraform output` as sensitive operational
data and store it only in an approved location.

## 6. Remote state and Terraform deployment

### Isolation model

| State area | Storage/locking | Trust boundary |
|---|---|---|
| Bootstrap | Own versioned, KMS-encrypted S3 bucket; bootstrap DynamoDB lock table | Management-account bootstrap credentials |
| Each of nine environment roots | Separate versioned S3 bucket, KMS key, and S3 `.tflock` lock file | Dedicated `TerraformStateAccess-*` role |

Environment bucket names use
`<STATE_BUCKET_PREFIX>-<MANAGEMENT_ACCOUNT_ID>-<environment>` and each key is
`<environment>/terraform.tfstate`. Generated `backend.hcl` files use mode
`0600`, are ignored by Git, and must not be hand-edited or committed. Their
backend role controls state access; `terraform_role_arn` in the environment
variables separately controls provider access to the target account.

This separates routine state access between environments, not management
account administrators. The stronger account-level boundary is to place the
state backend in a dedicated state account; this repository does not implement
that bootstrap.

### Configure environment values

1. Make a local copy of each required example, for example:

   ```sh
   cp environments/management/terraform.tfvars.example environments/management/terraform.tfvars
   ```

2. Replace each placeholder using actual bootstrap outputs, Identity Center
   group IDs, network-approved values, and existing execution role ARNs. The
   management root needs account IDs for security, network, dev, stage, and
   prod plus the synchronized group IDs listed in [Identity Center access](#provisioned-access-in-this-repository).
   Shared Services needs `<AD_DNS_DOMAIN_NAME>` in `ad_directory_name`.
   The security root needs `<MANAGEMENT_ACCOUNT_ID>` for its cross-account
   audit role trust.
3. Supply `ad_password` and `db_password` as `TF_VAR_ad_password` and
   `TF_VAR_db_password` from a secret manager/CI secret injection mechanism.
   Do not store real secrets in tfvars, plans, shell history, or Git. Terraform
   state still may contain their values.
4. Generate/refresh backend files from bootstrap outputs when needed:

   ```sh
   scripts/configure-backends.sh
   ```

5. Set `AWS_PROFILE=<DEPLOYER_PROFILE_FOR_ENVIRONMENT>` (or use an equivalent
   short-lived identity). That identity must be trusted by only the matching
   state role. The provider separately assumes
   `<TERRAFORM_EXECUTION_ROLE_ARN_ENV>` in the target account.

### Deploy one environment at a time

Recommended order:

1. Enable Identity Center in the management account, then configure the local
   `log-archive` variables from bootstrap outputs and apply `log-archive`.
   Set the same `<AWS_REGION>` used by management, and capture
   `cloudtrail_bucket_name` and `cloudtrail_kms_key_arn`.
2. Put those outputs in `management/terraform.tfvars`, configure real account
   IDs and empty group IDs, then apply `management`. This creates the
   organization trail and registers Security as the GuardDuty, Security Hub,
   and Config delegated administrator.
3. Apply `security` next. It enables GuardDuty organization enrollment,
   associates a Security Hub central policy with the Organizations root, and
   creates the Config aggregator. Verify account and Region coverage in the
   AWS consoles before proceeding.
4. Apply `network` with approved VPC and peer CIDRs. Capture the TGW output.
   The network state creates the firewall and fail-closed routing, but no spoke
   attachment is associated until its ID is supplied.
5. Apply `shared-services` to create the directory, DNS, and TGW attachment.
   Follow
   the [AD connection steps](#active-directory-sequence-and-important-placement-limitation),
   synchronize groups, fill group IDs, and apply `management` again.
6. Apply `workload-dev`, then `workload-stage`.
7. Apply `workload-prod` only after all production gates pass.
8. Apply `sandbox` as required.
9. From each deployed spoke root, run `terraform output
   transit_gateway_attachment_id`; add each ID to
   `network/terraform.tfvars` under `transit_gateway_spoke_attachment_ids` (key
   by account/environment), ensure its account is in
   `transit_gateway_spoke_account_ids`, then plan/review/reapply `network`.
   Add each spoke's approved workload CIDRs to `inspection_peer_cidrs` and its
   Suricata allow rules to `inspection_stateful_allow_rules`. Until this is
   done, transit traffic is intentionally blocked.

Each environment root enables AWS Config recording in its current provider
Region and stores Config history in a private, versioned bucket in that account.
The Security aggregator can collect enabled Regions across the Organization,
but a recorder must exist in each one. GuardDuty enrollment is regional; repeat
the management/security deployment with the same delegated administrator in
every approved Region. Security Hub central configuration links all supported
Regions from its home Region and applies the root policy across the linked
Regions and organization accounts. Verify Region opt-in, account enrollment,
and policy status. The Config recorder covers supported resource types, but
this configuration does not add Config conformance packs or rules. The
CloudTrail organization trail is multi-Region.

The central CloudTrail bucket, S3 access-log bucket, and KMS key are protected
against Terraform destruction. Both buckets use versioning; S3 server-access
logs are delivered to the separate access-log bucket. Lifecycle expiration is
disabled by default. After legal, audit, and cost owners approve the period,
set `cloudtrail_log_retention_days` in `log-archive/terraform.tfvars` to
`<APPROVED_LOG_RETENTION_DAYS>` (an integer of at least 90). This expires current
objects and noncurrent versions; it is not a substitute for an approved archive
or legal hold policy.

Security EventBridge rules in the Security account's configured Region send
GuardDuty findings with severity 7+ and active HIGH/CRITICAL Security Hub
findings to `security_alerts_topic_arn`. Set `security_alert_email` to a
monitored address and confirm its SNS subscription. Test a notification and
provide an operational incident destination before production. These rules do
not yet aggregate findings from other Regions.

For each configured environment:

```sh
AWS_PROFILE="<DEPLOYER_PROFILE_FOR_ENVIRONMENT>" \
  scripts/deploy-environment.sh workload-dev
```

The script runs init, validate, and plan; shows the saved plan and applies that
exact plan only after you type `APPLY <environment>`. Review every deletion,
account, IAM, network, and security change before approval. Do not use
`scripts/deploy-all.sh` for initial rollout: it does not resolve dependencies,
populate outputs, or make incomplete roots production-ready.

After deploying the network root, use `<TRANSIT_GATEWAY_ID>` from its output in
each spoke's local tfvars. Fill only approved account IDs and route CIDRs. Test
RAM sharing, attachments, forward and return routes, DNS, security groups, and
failure paths before sending workload traffic.

If upgrading a previously deployed checkout that used a shared state bucket,
migrate each environment's state once and verify it before any apply:

```sh
terraform -chdir=environments/network init -migrate-state -backend-config=backend.hcl
```

Repeat for each affected environment. Back up state and review the migration
prompt. Do not migrate a state file into an environment that already has an
independently managed state.

## 7. Existing accounts: invitation and adoption

This process is for the five existing accounts (or other standalone member
accounts). **Do not run the new-Organization bootstrap to adopt them.**

### Inventory each account

Before any invitation, collect `<EXISTING_ACCOUNT_ID>`, root email owner,
current Organization, workload owner, critical jobs, IAM roles/users, cross-
account trusts, credentials, regions, VPC CIDRs, quotas, Marketplace use,
backup/restore needs, security services, costs, and billing requirements.
Coordinate with account owners. Export configurations and reports that must be
retained; check for duplicate trails/services and unexpected charges.

### Invite and verify one account at a time

1. Confirm the destination Organization is the intended one and that the
   account is standalone. An account can belong to only one Organization.
2. From the destination management account, invite the account:

   ```sh
   aws organizations invite-account-to-organization \
     --target "Id=<EXISTING_ACCOUNT_ID>,Type=ACCOUNT"
   ```

3. In the invited account, an authorized administrator accepts the invitation
   using the console or the handshake ID:

   ```sh
   aws organizations accept-handshake --handshake-id "<HANDSHAKE_ID>"
   ```

4. Verify membership, place the account in a reviewed onboarding OU, and test
   workforce access, critical jobs, logging, billing, backups, and support.
   Move it to its permanent OU only after validation.
5. Create a reviewed, least-privilege Terraform execution role in the invited
   account and set `<TERRAFORM_EXECUTION_ROLE_ARN_ENV>` to its ARN. Invited
   accounts do **not** automatically receive
   `OrganizationAccountAccessRole`.
6. Adopt resources via a separate reviewed Terraform workflow. Inventory
   resource ownership and import existing resources before declaring them;
   never let a Terraform apply recreate or replace existing production
   resources unintentionally.

Joining does not move resources or change account IDs, but consolidated
billing and organization-level policies/services can affect the account.
Future charges go to the destination management account; historical billing
does not simply transfer. Keep the account root protected until new access and
recovery are tested.

After delegation is active, verify that GuardDuty enrolled the invited account
in each configured Region and that the Security Hub root policy applied to it
in all linked Regions. The organization trail will include member accounts,
but the Config aggregator only sees a Region after AWS Config recording is
enabled there. Adopt the account into a dedicated
Terraform root or deploy the Config recorder module with its reviewed execution
role; invitation alone does not provision its recorder.

If it belongs to another Organization, coordinate removal with that
Organization's management account and assess billing/security impacts before
inviting. An existing Organization management account cannot be invited as a
member; normally retain that Organization and move its member workloads as
needed. Do not attempt to reparent the former management account as an ordinary
member.

## 8. Account layout, network placement, and latency

Bootstrap creates the following member accounts:

| OU | Accounts |
|---|---|
| Security | Log Archive, Security Tooling |
| Infrastructure | Network, Shared Services |
| Workloads-Prod | Production |
| Workloads-NonProd | Staging, Development |
| Sandbox | Sandbox |

Management is pre-existing. Separate production, non-production, security, and
network boundaries as the organization grows. Use explicit account owners,
cost center, data classification, recovery objective, and access groups for
each account. Do not place application workloads in the management account.

### Service placement

- **Network account:** TGW, AWS Network Firewall in each used AZ when
  inspection is required, NAT only where needed, and VPN/Direct Connect
  termination if needed. Third-party firewall appliances need a separate
  failure/scaling/licensing design (for example GWLB).
- **Shared Services:** private DNS/resolver and AD only where required. Resolver
  endpoints need multiple AZs; configure forwarding and private-zone
  associations explicitly. Limit directory ports to approved client CIDRs.
- **Log Archive:** encrypted organization CloudTrail destination and S3
  server-access logging are configured. Lifecycle expiration is disabled until
  legal/audit owners approve retention; verify log delivery, alert routing, and
  restore procedures operationally.
- **Security Tooling:** delegated GuardDuty/Security Hub administration and an
  organization Config aggregator are configured for the selected Region.
- **Workload accounts:** private app/data subnets across AZs; public subnets
  only for explicit internet-facing endpoints; RDS in isolated DB subnets.
  Consider gateway endpoints for S3/DynamoDB and interface endpoints for
  frequently used services.
- **WAF** is a managed service associated with CloudFront, ALB, or API Gateway,
  not an appliance that belongs in a VPC. Evaluate Shield against availability
  and risk requirements.

### Low latency and safe routing

- Keep chatty services and databases in the same Region; use local VPC routing
  for same-VPC traffic.
- Avoid unnecessary TGW, firewall, NAT, cross-AZ, or cross-Region hops. Central
  inspection improves control, not latency.
- Use per-AZ NAT/firewall endpoints when availability and traffic justify the
  cost. Design symmetric return paths and avoid centralized egress hairpins
  unless required by policy.
- Check non-overlapping CIDRs across VPCs, on-premises, and acquisitions.
- Measure application p50/p95/p99 and VPC Flow Logs before and after routing
  changes; test failover and cross-AZ paths before production.

### Inspection VPC NACL and Network Firewall

The network root creates two TGW attachment subnets and one dedicated firewall
subnet per available AZ. It associates a custom network ACL with all of them.
The ACL allows all protocols only to/from the inspection VPC CIDR and the
configured `inspection_peer_cidrs`; the AWS implicit deny blocks everything
else. The default NACL rule quota is 20 per direction, so the input is limited
to 19 peer CIDRs plus the inspection VPC CIDR. Request a quota increase and
update the validation only after AWS approval if more ranges are required.

AWS Network Firewall is deployed in each used AZ with flow and alert logs in
CloudWatch Logs. Its stateful rule group is strict-order and appends a catch-all
drop. No user allow rules means all inspected traffic is denied. Define narrow,
reviewed Suricata rules; do not use broad `pass ip any any` rules. The firewall
is a paid service billed per endpoint-hour and traffic processed.

Routing sequence: the TGW spoke route table directs traffic to the inspection
attachment; the inspection TGW route table learns spoke routes; each firewall
subnet routes approved peer CIDRs back to TGW; each TGW attachment subnet sends
traffic to its same-AZ firewall endpoint. Preserve symmetric routing and keep
firewall subnets separate from TGW attachment subnets. No Internet Gateway,
NAT gateway, VPN, Direct Connect, or centralized internet-egress inspection is
created. Route changes can interrupt traffic; inspect saved plans and test
return paths before applying.

## 9. SCPs and guardrails

SCPs define maximum permissions for member-account principals; they do not
grant access and do not replace IAM or Identity Center assignments. SCPs do not
restrict the Organizations management account, and generally do not restrict
service-linked roles. They can still block critical member-account changes.
Do not attach unreviewed deny policies to the Organization root.

The bootstrap attaches `baseline-scp.json` to the Security, Infrastructure,
Production, Non-Production, and Sandbox OUs (not the Organization root or
management account). It denies `organizations:LeaveOrganization` and denies
`iam:CreateAccessKey` when the principal is an account root user. These are
member-account guardrails; moving an account between OUs changes its inherited
SCPs. Confirm the baseline in the Organizations console after bootstrap.

The repository also has three optional sample JSON policies:

| Policy | Intended scope | Current concern |
|---|---|---|
| `prod-scp.json` | Production overlay | CMK and public-S3 conditions need correction/validation; its current `DenyDetachFlowLogs` also blocks VPC endpoint deletion |
| `nonprod-scp.json` | Non-production limits | Narrow instance-size list only; not a general encryption/network baseline |
| `sandbox-scp.json` | Sandbox limits | Blocks EKS and RDS; retain only if that is an approved business rule |

The former broad MFA and S3 delete denies, and the unexcepted Region deny, were
removed from the baseline: MFA for federated sessions belongs at the identity
provider/Identity Center, and region allowlists require an organization-approved
Region/global-service design. Do not copy those statements into a production
SCP without testing. Before attaching any optional policy, validate it with
AWS policy tools and service-specific condition-key documentation, test in a
disposable non-production account, then stage on intended OUs and monitor
denials. Protect CloudTrail, Config, GuardDuty, Security Hub, and log delivery
only with validated actions/conditions and documented recovery.

The baseline is attached by bootstrap Terraform; optional samples remain
unattached.

## 10. Production go-live gates and routine operation

Do not place production workloads under this scaffold until all applicable
gates are complete:

- [ ] Security and account owners approve the OU/account plan, break-glass
  process, and service quotas.
- [ ] Organization CloudTrail, S3 access logging, high-severity notifications,
  and protected centralized log storage are verified; retention is approved
  and restore-tested.
- [ ] Config recording, aggregation, and delegated GuardDuty/Security Hub
  administration are verified for every enabled Region and member account.
- [ ] Identity Center source, MFA, groups, assignments, joiner/mover/leaver,
  and recovery have been tested. Production write access uses an approved
  deployment role/process.
- [ ] SCPs are validated and staged; no policy blocks required recovery,
  service-linked, or platform operations.
- [ ] Network Firewall and NACL policies, spoke attachments, approved rules,
  DNS, TGW routes, symmetry, capacity, VPC endpoints, and failover are
  implemented and tested. Internet egress inspection is separate scope.
- [ ] Backups and application recovery are tested; alarms, incident response,
  retention, and audit processes are operational.
- [ ] Remote state access is restricted, state recovery is tested, and secrets
  are injected without committing them.
- [ ] Exact Terraform plan reviewed and approved by the environment owner.

Routine cadence:

- Review group membership, privileged account assignments, IAM trust, SCP
  exceptions, costs, quotas, drift, and backups at least quarterly.
- Use reviewed changes and one environment plan at a time. Preserve saved plans,
  approvals, and change tickets according to organizational policy.
- For a suspected identity compromise, disable the identity upstream and
  revoke sessions where possible. For AWS compromise, preserve CloudTrail and
  workload evidence, revoke credentials, and follow the incident plan.
- Keep backend buckets/keys access-limited; never publish state or generated
  backend files.
- Test account, state, log, and workload recovery periodically.

## 11. AWS references

- [AWS Organizations: inviting accounts](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_invites.html)
- [AWS Organizations: accepting invitations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_accept-decline-invite.html)
- [AWS Organizations: access roles for invited accounts](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create-cross-account-role.html)
- [AWS account root user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html)
- [Centralized root access for member accounts](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-enable-root-access.html)
- [IAM Identity Center CLI credentials](https://docs.aws.amazon.com/singlesignon/latest/userguide/howtogetcredentials.html)
- [IAM Identity Center external identity providers](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-idp.html)
- [IAM Identity Center and Microsoft AD](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-ad.html)
- [Connect AWS Managed Microsoft AD to Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/connectawsad.html)
- [Synchronize an administrative user from AD](https://docs.aws.amazon.com/singlesignon/latest/userguide/get-started-connect-id-source-ad-idp-specify-user.html)
