bucket         = "enterprise-landing-zone-state"
key            = "workload-dev/prod.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "enterprise-landing-zone-locks"
