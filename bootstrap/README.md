# Bootstrap

This folder creates the AWS Organizations foundation and remote state resources.
For the complete architecture, federation, account adoption, and go-live steps,
see the [self-managed landing-zone runbook](../docs/SELF-MANAGED-LANDING-ZONE-RUNBOOK.md).

Before running it, copy `bootstrap/terraform.tfvars.example` to
`bootstrap/terraform.tfvars` and replace every `<PLACEHOLDER>`. Required values
include the real management account ID, unique account emails, globally unique
bootstrap bucket name, lowercase state-bucket prefix, and nine distinct,
existing trusted deployer-role ARNs. The Terraform AWS provider refuses to run unless the current
account matches `expected_management_account_id`.

Use the guarded bootstrap entrypoint; it initializes locally, displays a plan,
and requires explicit approval because it creates accounts and an Organization:

```sh
scripts/bootstrap-state.sh
```

Review the plan carefully. This creates an AWS Organization, member accounts,
one bootstrap state bucket and nine isolated environment state buckets. Do not
run it if an Organization already exists.

Required actions:
1. Start with an AWS management account.
2. Create OUs and member accounts with unique, controlled email addresses.
3. Create the versioned, private, KMS-encrypted state buckets and per-environment
   state access roles.
4. Migrate bootstrap state to its own bucket and generate each ignored
   `environments/<name>/backend.hcl`.
5. Grant each trusted source role `sts:AssumeRole` only to its matching state
   role. Keep workload execution roles separate from state access roles.
6. Configure workload execution roles and run environment roots only after
   bootstrap succeeds.

## Planning an environment

After bootstrap succeeds, all environment `backend.hcl` files are generated.
The backend assumes its environment-specific state role from the active AWS
credentials; the AWS provider separately assumes `terraform_role_arn` for the
target account. Initialize and plan a root, for example:

```sh
terraform -chdir=environments/network init -backend-config=backend.hcl
terraform -chdir=environments/network plan
```

For an existing environment that used the old shared bucket, migrate its state
once before using the deployment wrapper:

```sh
terraform -chdir=environments/network init -migrate-state -backend-config=backend.hcl
```

`terraform init -backend=false` is useful for local module initialization and
`terraform validate`, but `terraform plan` still requires the configured S3
backend. If you only want a no-AWS structural check, run `terraform validate`.
For a local plan, use an isolated scratch copy with the S3 backend block
removed; never apply that local-state plan to production.

## Important

Run bootstrap only from the management account. The environment state buckets
are separate but remain in that account; a dedicated state account is required
for an account-level isolation boundary.
