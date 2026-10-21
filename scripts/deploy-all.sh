#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -gt 1 ]]; then
	echo "Usage: $0 [environment]" >&2
	exit 2
fi

if [[ $# -eq 1 ]]; then
	exec "$script_dir/deploy-environment.sh" "$1"
fi

for environment in management security network shared-services sandbox workload-dev workload-stage workload-prod; do
	"$script_dir/deploy-environment.sh" "$environment"
done
