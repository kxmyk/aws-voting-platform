variable "ecs_service_desired_counts" {
  description = "Desired task counts indexed by application service."
  type        = map(number)

  default = {
    vote   = 1
    result = 1
    worker = 1
  }

  validation {
    condition = (
      toset(keys(var.ecs_service_desired_counts)) == var.ecs_service_names &&
      alltrue([
        for desired_count in values(var.ecs_service_desired_counts) :
        desired_count >= 0 && floor(desired_count) == desired_count
      ])
    )

    error_message = "ecs_service_desired_counts must define a non-negative integer for every ECS service."
  }
}

variable "ecs_service_health_check_grace_period_seconds" {
  description = "Time allowed for load-balanced ECS tasks to pass health checks."
  type        = number
  default     = 90

  validation {
    condition = (
      var.ecs_service_health_check_grace_period_seconds >= 0 &&
      var.ecs_service_health_check_grace_period_seconds <= 2147483647
    )

    error_message = "ecs_service_health_check_grace_period_seconds must be a valid ECS grace period."
  }
}

variable "ecs_service_wait_for_steady_state" {
  description = "Whether Terraform waits for ECS services to reach a steady state."
  type        = bool
  default     = true
}
