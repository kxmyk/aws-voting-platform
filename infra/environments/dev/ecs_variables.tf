variable "ecs_service_names" {
  description = "Application services managed by the ECS foundation."
  type        = set(string)

  default = [
    "vote",
    "result",
    "worker"
  ]

  validation {
    condition = (
      length(var.ecs_service_names) > 0 &&
      alltrue([
        for service_name in var.ecs_service_names :
        length(service_name) >= 1 &&
        length(service_name) <= 30 &&
        can(regex("^[a-z0-9-]+$", service_name))
      ])
    )

    error_message = "ecs_service_names must contain valid lowercase service names."
  }
}

variable "ecs_log_retention_days" {
  description = "Number of days that ECS container logs are retained."
  type        = number
  default     = 7

  validation {
    condition = contains(
      [
        1,
        3,
        5,
        7,
        14,
        30,
        60,
        90,
        120,
        150,
        180,
        365
      ],
      var.ecs_log_retention_days
    )

    error_message = "ecs_log_retention_days must be a supported CloudWatch Logs retention value."
  }
}

variable "ecs_container_insights_enabled" {
  description = "Whether CloudWatch Container Insights is enabled for the development ECS cluster."
  type        = bool
  default     = false
}

variable "ecs_enable_fargate_spot" {
  description = "Whether FARGATE_SPOT is associated with the development ECS cluster."
  type        = bool
  default     = true
}
