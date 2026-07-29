locals {
  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "Terraform"
    Repository  = "kxmyk/aws-voting-platform"
    Owner       = "Kamil"
  }
}
