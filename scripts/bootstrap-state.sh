#!/usr/bin/env bash
set -euo pipefail

aws s3api create-bucket \
  --bucket enterprise-landing-zone-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket enterprise-landing-zone-state \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket enterprise-landing-zone-state \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"alias/aws/s3"}}]}'

aws dynamodb create-table \
  --table-name enterprise-landing-zone-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
