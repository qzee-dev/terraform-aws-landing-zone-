#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$script_dir/.." && pwd)"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <management|security|network|shared-services|sandbox|workload-dev|workload-stage|workload-prod>" >&2
  exit 2
fi

environment="$1"
case "$environment" in
  management|security|network|shared-services|sandbox|workload-dev|workload-stage|workload-prod) ;;
  *)
    echo "Unknown environment: $environment" >&2
    exit 2
    ;;
esac

environment_dir="$repo_dir/environments/$environment"
backend_config="$environment_dir/backend.hcl"
variables_file="$environment_dir/terraform.tfvars"

if [[ ! -f "$backend_config" ]]; then
  echo "Missing backend configuration: $backend_config" >&2
  exit 1
fi

if [[ ! -f "$variables_file" ]]; then
  echo "Missing environment variables: $variables_file" >&2
  echo "Create this ignored local file with expected_account_id, terraform_role_arn, and required environment inputs." >&2
  exit 1
fi

if [[ ! -t 0 ]]; then
  echo "Interactive approval is required; refusing to deploy without a terminal." >&2
  exit 1
fi

umask 077
plan_file="$(mktemp "${TMPDIR:-/tmp}/landing-zone-${environment}.XXXXXX")"
trap 'rm -f "$plan_file"' EXIT

terraform -chdir="$environment_dir" init -input=false -backend-config=backend.hcl
terraform -chdir="$environment_dir" validate
terraform -chdir="$environment_dir" plan -input=false -out="$plan_file"
terraform -chdir="$environment_dir" show -no-color "$plan_file"

approval="APPLY $environment"
read -r -p "Type '$approval' to apply this exact plan: " response
if [[ "$response" != "$approval" ]]; then
  echo "Approval did not match; no changes were applied." >&2
  exit 1
fi

terraform -chdir="$environment_dir" apply -input=false "$plan_file"