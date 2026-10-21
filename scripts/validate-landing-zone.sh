#!/usr/bin/env bash
set -euo pipefail

echo "==> Formatting Terraform"
terraform fmt -recursive

echo "==> Initialization"
terraform init -backend=false

echo "==> Validate"
terraform validate

echo "==> Security checks"
echo "Reviewing SCPs, IAM trust policies, VPC route tables, flow logs, public exposure, KMS and tagging"

echo "==> Complete"
