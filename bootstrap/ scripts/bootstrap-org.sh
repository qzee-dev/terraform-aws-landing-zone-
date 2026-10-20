#!/usr/bin/env bash
set -euo pipefail

echo "Bootstrap organization and accounts"
echo "Run this in the Management account only"

# Example actions
# aws organizations create-organization --feature-set ALL
# aws organizations list-roots
# aws organizations create-organizational-unit --name "Security-OU" --parent-id <ROOT_ID>
# aws organizations create-account --account-name "network" --email "network@example.com" --parent-id <OU_ID>
