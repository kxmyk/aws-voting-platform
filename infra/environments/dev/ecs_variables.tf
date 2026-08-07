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

variable "ecs_bootstrap_image_tag" {
  description = "Immutable ECR image tag used for the initial ECS task definition revisions."
  type        = string
  default     = "sha-574373bfdd41"

  validation {
    condition = can(regex(
      "^sha-[0-9a-f]{12}$",
      var.ecs_bootstrap_image_tag
    ))

    error_message = "ecs_bootstrap_image_tag must use the sha-<12 hex characters> format."
  }
}

variable "ecs_task_cpu" {
  description = "CPU units assigned to each development Fargate task."
  type        = number
  default     = 256

  validation {
    condition     = var.ecs_task_cpu == 256
    error_message = "The development baseline currently uses 256 CPU units (0.25 vCPU)."
  }
}

variable "ecs_task_memory" {
  description = "Memory in MiB assigned to each development Fargate task."
  type        = number
  default     = 512

  validation {
    condition = contains(
      [512, 1024, 2048],
      var.ecs_task_memory
    )

    error_message = "For 256 Fargate CPU units, memory must be 512, 1024, or 2048 MiB."
  }
}
