#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
terraform_roots=("$repo_dir/bootstrap")
for environment_dir in "$repo_dir"/environments/*; do
  [[ -d "$environment_dir" ]] && terraform_roots+=("$environment_dir")
done

echo "==> Checking Terraform formatting"
terraform fmt -check -recursive "$repo_dir"

for terraform_root in "${terraform_roots[@]}"; do
  echo "==> Validating ${terraform_root#"$repo_dir"/}"
  terraform -chdir="$terraform_root" init -backend=false -input=false
  terraform -chdir="$terraform_root" validate
done

echo "==> Checking SCP JSON syntax"
for policy in "$repo_dir"/policies/*.json; do
  jq -e . "$policy" >/dev/null
done

echo "Terraform roots and SCP JSON syntax checks passed."
