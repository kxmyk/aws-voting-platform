locals {
  ecs_ecr_repository_arns = {
    for service_name in var.ecs_service_names :
    service_name => join("", [
      "arn:aws:ecr:",
      var.aws_region,
      ":",
      data.aws_caller_identity.current.account_id,
      ":repository/",
      var.project_name,
      "/",
      service_name
    ])
  }
}

module "ecs" {
  source = "../../modules/ecs"

  name          = "${var.project_name}-${var.environment}"
  service_names = var.ecs_service_names

  ecr_repository_arns = toset(
    values(local.ecs_ecr_repository_arns)
  )

  secrets_manager_secret_arns = toset([
    module.postgres.master_user_secret_arn
  ])

  log_retention_days         = var.ecs_log_retention_days
  container_insights_enabled = var.ecs_container_insights_enabled
  enable_fargate_spot        = var.ecs_enable_fargate_spot

  tags = local.common_tags
}
