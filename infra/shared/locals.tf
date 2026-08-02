locals {
  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "Terraform"
    Repository  = "${var.github_owner}/${var.github_repository}"
    Owner       = "Kamil"
  }

  github_repository_full_name = "${var.github_owner}/${var.github_repository}"

  github_oidc_subjects = [
    for branch in sort(tolist(var.github_allowed_branches)) :
    join("", [
      "repo:",
      var.github_owner,
      "@",
      var.github_owner_id,
      "/",
      var.github_repository,
      "@",
      var.github_repository_id,
      ":ref:refs/heads/",
      branch
    ])
  ]

  github_main_oidc_subject = join("", [
    "repo:",
    var.github_owner,
    "@",
    var.github_owner_id,
    "/",
    var.github_repository,
    "@",
    var.github_repository_id,
    ":ref:refs/heads/main"
  ])
}
