output "org_id" {
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
