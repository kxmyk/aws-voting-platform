locals {
  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "Terraform"
    Repository  = "${var.github_owner}/${var.github_repository}"
    Owner       = "Kamil"
  }

  github_repository_full_name = "${var.github_owner}/${var.github_repository}"

  github_oidc_subject = join("", [
    "repo:",
    local.github_repository_full_name,
    ":ref:refs/heads/",
    var.github_deployment_branch
  ])
}
