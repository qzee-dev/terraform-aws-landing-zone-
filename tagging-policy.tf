locals {
  required_tags = {
    Environment = "Prod"
    ProjectID   = "medical-platform"
    Owner       = "platform-team"
    CostCenter  = "CC-1001"
    Compliance  = "HIPAA"
    Automation  = "Terraform"
  }
}

resource "aws_resourcegroups_group" "this" {
  name = "medical-platform-resource-group"

  resource_query {
    type = "TAG_FILTERS_1_0"
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupportedResources"]
      TagFilters = [
        {
          Key    = "Environment"
          Values = ["Prod"]
        }
      ]
    })
  }
}
