#!/usr/bin/env bash
set -euo pipefail

echo "==> Deploying management"
terraform -chdir=environments/management init
terraform -chdir=environments/management plan
terraform -chdir=environments/management apply -auto-approve

echo "==> Deploying security"
terraform -chdir=environments/security init
terraform -chdir=environments/security plan
terraform -chdir=environments/security apply -auto-approve

echo "==> Deploying network"
terraform -chdir=environments/network init
terraform -chdir=environments/network plan
terraform -chdir=environments/network apply -auto-approve

echo "==> Deploying shared-services"
terraform -chdir=environments/shared-services init
terraform -chdir=environments/shared-services plan
terraform -chdir=environments/shared-services apply -auto-approve

echo "==> Deploying workload-prod"
terraform -chdir=environments/workload-prod init
terraform -chdir=environments/workload-prod plan
terraform -chdir=environments/workload-prod apply -auto-approve

echo "==> Deploying workload-stage"
terraform -chdir=environments/workload-stage init
terraform -chdir=environments/workload-stage plan
terraform -chdir=environments/workload-stage apply -auto-approve

echo "==> Deploying workload-dev"
terraform -chdir=environments/workload-dev init
terraform -chdir=environments/workload-dev plan
terraform -chdir=environments/workload-dev apply -auto-approve

echo "==> Deploying sandbox"
terraform -chdir=environments/sandbox init
terraform -chdir=environments/sandbox plan
terraform -chdir=environments/sandbox apply -auto-approve
