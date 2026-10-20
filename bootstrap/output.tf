output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "security_ou_id" {
  value = aws_organizations_organizational_unit.security.id
}

output "infrastructure_ou_id" {
  value = aws_organizations_organizational_unit.infrastructure.id
}

output "workloads_prod_ou_id" {
  value = aws_organizations_organizational_unit.workloads_prod.id
}

output "workloads_nonprod_ou_id" {
  value = aws_organizations_organizational_unit.workloads_nonprod.id
}

output "sandbox_ou_id" {
  value = aws_organizations_organizational_unit.sandbox.id
}

output "network_account_id" {
  value = aws_organizations_account.network.id
}

output "shared_system_account_id" {
  value = aws_organizations_account.shared_system.id
}

output "production_account_id" {
  value = aws_organizations_account.production.id
}

output "staging_account_id" {
  value = aws_organizations_account.staging.id
}

output "development_account_id" {
  value = aws_organizations_account.development.id
}

output "sandbox_account_id" {
  value = aws_organizations_account.sandbox.id
}

output "state_bucket_name" {
  value = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.locks.name
}
