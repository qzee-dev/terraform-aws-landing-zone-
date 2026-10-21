aws_region = "us-east-1"

organization_name = "enterprise-org"

ou_security_name = "Security-OU"
ou_infrastructure_name = "Infrastructure-OU"
ou_workloads_prod_name = "Workloads-Prod-OU"
ou_workloads_nonprod_name = "Workloads-NonProd-OU"
ou_sandbox_name = "Sandbox-OU"

management_account_email = "management@example.com"
log_archive_account_email = "log-archive@example.com"
security_tooling_account_email = "security-tooling@example.com"
network_account_email = "network@example.com"
shared_system_account_email = "shared-system@example.com"
production_account_email = "prod@example.com"
staging_account_email = "staging@example.com"
development_account_email = "dev@example.com"
sandbox_account_email = "sandbox@example.com"

state_bucket_name = "enterprise-landing-zone-state"
lock_table_name = "enterprise-landing-zone-locks"

project_name = "medical-platform"
environment = "prod"

db_password = "REPLACE_WITH_STRONG_PASSWORD"
ad_password = "REPLACE_WITH_STRONG_PASSWORD"

onprem_cidrs = [
  "10.0.0.0/8"
]

management_account_id = "111111111111"
security_account_id = "222222222222"
network_account_id = "333333333333"
shared_system_account_id = "444444444444"
production_account_id = "555555555555"
