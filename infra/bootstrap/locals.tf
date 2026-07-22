locals {
  state_bucket_name = join("-", [
    var.project_name,
    "tfstate",
    data.aws_caller_identity.current.account_id,
    var.aws_region
  ])

  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "Terraform"
    Repository  = "kxmyk/aws-voting-platform"
    Owner       = "Kamil"
  }
}
