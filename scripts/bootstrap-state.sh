#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bootstrap_dir="$repo_dir/bootstrap"
variables_file="$bootstrap_dir/terraform.tfvars"

if [[ ! -f "$variables_file" ]]; then
  echo "Missing $variables_file. Copy bootstrap/terraform.tfvars.example and replace every placeholder." >&2
  exit 1
fi

if [[ ! -t 0 ]]; then
  echo "Interactive approval is required; refusing to bootstrap without a terminal." >&2
  exit 1
fi

umask 077
plan_file="$(mktemp "${TMPDIR:-/tmp}/landing-zone-bootstrap.XXXXXX")"
trap 'rm -f "$plan_file"' EXIT

terraform -chdir="$bootstrap_dir" init -backend=false -input=false
terraform -chdir="$bootstrap_dir" validate
terraform -chdir="$bootstrap_dir" plan -input=false -out="$plan_file"
terraform -chdir="$bootstrap_dir" show -no-color "$plan_file"

read -r -p "Type 'APPLY BOOTSTRAP' to create the Organization, accounts, and state backend: " response
if [[ "$response" != "APPLY BOOTSTRAP" ]]; then
  echo "Approval did not match; no changes were applied." >&2
  exit 1
fi

terraform -chdir="$bootstrap_dir" apply -input=false "$plan_file"

state_bucket="$(terraform -chdir="$bootstrap_dir" output -raw state_bucket_name)"
lock_table="$(terraform -chdir="$bootstrap_dir" output -raw lock_table_name)"
state_region="$(terraform -chdir="$bootstrap_dir" output -raw aws_region)"

terraform -chdir="$bootstrap_dir" init -input=false -migrate-state -force-copy \
  -backend-config="bucket=$state_bucket" \
  -backend-config="key=bootstrap/terraform.tfstate" \
  -backend-config="region=$state_region" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=$lock_table"

echo "Bootstrap state has been migrated to the created S3 backend."
