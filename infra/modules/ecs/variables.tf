variable "name" {
  description = "Name prefix used for ECS resources."
  type        = string

  validation {
    condition = (
      length(var.name) >= 3 &&
      length(var.name) <= 40 &&
      can(regex("^[a-z0-9-]+$", var.name))
    )

    error_message = "name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "service_names" {
  description = "Application services that run in the ECS cluster."
  type        = set(string)

  validation {
    condition = (
      length(var.service_names) > 0 &&
      alltrue([
        for service_name in var.service_names :
        length(service_name) >= 1 &&
        length(service_name) <= 30 &&
        can(regex("^[a-z0-9-]+$", service_name))
      ])
    )

    error_message = "service_names must contain valid lowercase service names."
  }
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs from which ECS tasks may pull images."
  type        = set(string)

  validation {
    condition = (
      length(var.ecr_repository_arns) > 0 &&
      alltrue([
        for repository_arn in var.ecr_repository_arns :
        can(regex("^arn:aws:ecr:[a-z0-9-]+:[0-9]{12}:repository/.+$", repository_arn))
      ])
    )

    error_message = "ecr_repository_arns must contain valid private ECR repository ARNs."
  }
}

variable "log_retention_days" {
  description = "Number of days that container logs are retained in CloudWatch Logs."
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
      var.log_retention_days
    )

    error_message = "log_retention_days must be a supported CloudWatch Logs retention value."
  }
}

variable "container_insights_enabled" {
  description = "Whether CloudWatch Container Insights is enabled for the ECS cluster."
  type        = bool
  default     = false
}

variable "enable_fargate_spot" {
  description = "Whether the FARGATE_SPOT capacity provider is associated with the ECS cluster."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to ECS, IAM and CloudWatch resources."
  type        = map(string)
  default     = {}
}
