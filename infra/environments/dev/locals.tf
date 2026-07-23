locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "kxmyk/aws-voting-platform"
    Owner       = "Kamil"
  }
}
