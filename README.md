# Self-Managed AWS Landing Zone

This repository is a Terraform scaffold for a self-managed AWS Organizations
landing zone. **AWS Control Tower is not used. This is not production-ready as
checked in.**

Read the canonical [Self-Managed Landing Zone Runbook](docs/SELF-MANAGED-LANDING-ZONE-RUNBOOK.md)
before running Terraform. It contains the architecture, placeholder inventory,
new-Organization sequence, state bootstrap, Entra/AD federation, permissions,
existing-account adoption, network placement, SCP cautions, and go-live gates.

## What is included

- Organization bootstrap for an existing management account, OUs, and eight
  new member accounts.
- Nine isolated Terraform environment backends with per-environment S3
  buckets, KMS keys, S3 lockfiles, and backend roles.
- Organization CloudTrail delivery to a separate Log Archive account, with a
  dedicated KMS key, protected S3 bucket, and S3 server-access logging.
- GuardDuty and Security Hub delegated administration, AWS Config recorders in
  each environment root, an organization Config aggregator, and optional
  high-severity SNS email notifications.
- TGW-routed east-west inspection with a multi-AZ AWS Network Firewall and
  custom inspection-VPC NACL.
- An SCP baseline attached to the five member-account OUs. It blocks member
  accounts from leaving the Organization and prevents root access-key creation.
- Example Identity Center permission sets/assignments, Transit Gateway, VPCs,
  shared services, and workload roots.
- Approval-gated bootstrap and single-environment deployment scripts.

## Important limitations

- Do **not** run bootstrap against an existing Organization. This repository
  does not automatically adopt existing accounts.
- The production, non-production, and sandbox SCP examples are not attached.
  The baseline SCP is attached to member-account OUs but does not restrict the
  management account; review its effects before applying bootstrap.
- GuardDuty and each AWS Config recorder are configured in one selected Region.
  Security Hub central configuration links all supported Regions; verify the
  organization's enabled-Region and account coverage before production.
- Security Hub and GuardDuty usage, Config history storage, CloudTrail storage,
  and KMS use incur service charges; estimate and monitor costs.
- CloudTrail and S3 access-log expiration are disabled by default
  (`cloudtrail_log_retention_days = 0`); set an approved retention period only
  after legal and audit review.
- The firewall inspects only transit traffic whose spoke attachment IDs,
  peer CIDRs, and stateful allow rules have been configured. Empty allowlists
  are fail-closed. Internet egress/NAT inspection is not implemented.
- Identity Center must be enabled and connected to one workforce source before
  the management root is applied. Terraform does not configure SAML/SCIM or
  create/synchronize directory groups.
- State is segmented by environment but remains in the management account.
- Example CIDRs, emails, account IDs, group IDs, role ARNs, secrets, and service
  values are placeholders. Replace them with approved values locally; never
  commit credentials, secrets, generated backend files, or state.

## Start here

1. Read the [runbook](docs/SELF-MANAGED-LANDING-ZONE-RUNBOOK.md) and identify
   which values must be replaced with `<PLACEHOLDERS>`.
2. Decide whether this is a genuinely new Organization or an existing
   Organization to extend. Bootstrap is for a new Organization only.
3. Configure and review the local bootstrap values, then run
   `scripts/bootstrap-state.sh` only when its preconditions are satisfied.
4. Configure one environment at a time and use
   `scripts/deploy-environment.sh <environment>` to review and approve the exact
   plan.

Do not treat `terraform validate`, sample policies, or compliance tags as
evidence of live-account readiness or compliance.
