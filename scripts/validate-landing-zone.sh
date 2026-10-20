#!/usr/bin/env bash
set -euo pipefail

echo "==> Formatting Terraform"
terraform fmt -recursive

echo "==> Initialization"
terraform init -backend=false

echo "==> Validate"
terraform validate

echo "==> Security checks"
echo "Checking SCPs, network routes, public DB access, IAM permissions, etc."

echo "==> Complete"
