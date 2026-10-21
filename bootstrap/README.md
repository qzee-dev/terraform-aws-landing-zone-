# Bootstrap

This folder creates the AWS Organizations foundation and remote state resources.

Before running it, copy `bootstrap/terraform.tfvars.example` to
`bootstrap/terraform.tfvars` and replace the management account ID, every
member-account email, and the globally unique state bucket name. The Terraform
AWS provider refuses to run if the current account does not match
`expected_management_account_id`.

Use the guarded bootstrap entrypoint; it initializes locally, displays a plan,
and requires explicit approval because it creates accounts and an Organization:

```sh
scripts/bootstrap-state.sh
```

Review the plan carefully. This creates an AWS Organization, member accounts,
shared state resources, and the remote backend. Do not run it if an Organization
already exists.

Required actions:
1. Start with an AWS management account.
2. Create OUs and member accounts with unique, controlled email addresses.
3. Create the encrypted Terraform state bucket and lock table.
4. Secure and migrate the bootstrap root's local state to the created S3 backend.
5. Configure cross-account deployment roles and least-privilege access.
6. Run environment roots only after bootstrap succeeds.

## Planning an environment

After bootstrap succeeds, set the bucket and lock-table values in the target
environment's `backend.hcl`, then initialize and plan that root. For example:

```sh
terraform -chdir=environments/network init -backend-config=backend.hcl
terraform -chdir=environments/network plan
```

`terraform init -backend=false` is useful for local module initialization and
`terraform validate`, but `terraform plan` still requires the configured S3
backend. If you only want a no-AWS structural check, run `terraform validate`.
For a local plan, use an isolated scratch copy with the S3 backend block
removed; never apply that local-state plan to production.

## Important

This directory should only be executed from the management account.
