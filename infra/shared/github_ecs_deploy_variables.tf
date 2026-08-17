variable "github_ecs_deployment_environment" {
  description = "Temporary ECS environment that GitHub Actions is allowed to deploy."
  type        = string
  default     = "dev"

  validation {
    condition = (
      length(var.github_ecs_deployment_environment) >= 1 &&
      length(var.github_ecs_deployment_environment) <= 20 &&
      can(regex(
        "^[a-z0-9-]+$",
        var.github_ecs_deployment_environment
      ))
    )

    error_message = "github_ecs_deployment_environment must contain only lowercase letters, numbers, and hyphens."
  }
}
