variable "name" {
  description = "Name of the ECS service."
  type        = string

  validation {
    condition = (
      length(var.name) >= 3 &&
      length(var.name) <= 255 &&
      can(regex("^[a-zA-Z0-9_-]+$", var.name))
    )

    error_message = "name must be a valid ECS service name."
  }
}

variable "cluster_id" {
  description = "ID or ARN of the ECS cluster."
  type        = string

  validation {
    condition     = length(var.cluster_id) > 0
    error_message = "cluster_id must not be empty."
  }
}

variable "task_definition_arn" {
  description = "ARN of the task definition revision run by the service."
  type        = string

  validation {
    condition = can(regex(
      "^arn:aws:ecs:[a-z0-9-]+:[0-9]{12}:task-definition/.+:[0-9]+$",
      var.task_definition_arn
    ))

    error_message = "task_definition_arn must be a revision-specific ECS task definition ARN."
  }
}

variable "desired_count" {
  description = "Desired number of Fargate tasks."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 0 && floor(var.desired_count) == var.desired_count
    error_message = "desired_count must be a non-negative integer."
  }
}

variable "subnet_ids" {
  description = "Private application subnet IDs used by service tasks."
  type        = set(string)

  validation {
    condition = (
      length(var.subnet_ids) > 0 &&
      alltrue([
        for subnet_id in var.subnet_ids :
        can(regex("^subnet-[a-zA-Z0-9]+$", subnet_id))
      ])
    )

    error_message = "subnet_ids must contain at least one valid subnet ID."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to service tasks."
  type        = set(string)

  validation {
    condition = (
      length(var.security_group_ids) > 0 &&
      alltrue([
        for security_group_id in var.security_group_ids :
        can(regex("^sg-[a-zA-Z0-9]+$", security_group_id))
      ])
    )

    error_message = "security_group_ids must contain at least one valid security group ID."
  }
}

variable "assign_public_ip" {
  description = "Whether Fargate tasks receive public IPv4 addresses."
  type        = bool
  default     = false
}

variable "platform_version" {
  description = "Fargate platform version used by the service."
  type        = string
  default     = "LATEST"
}

variable "load_balancer_enabled" {
  description = "Whether the ECS service is registered with a target group."
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "Optional target group ARN used by a load-balanced service."
  type        = string
  default     = null
  nullable    = true
}

variable "container_name" {
  description = "Container registered in the target group."
  type        = string
  default     = null
  nullable    = true
}

variable "container_port" {
  description = "Container port registered in the target group."
  type        = number
  default     = null
  nullable    = true
}

variable "health_check_grace_period_seconds" {
  description = "Time allowed for a load-balanced task to become healthy."
  type        = number
  default     = 90

  validation {
    condition = (
      var.health_check_grace_period_seconds >= 0 &&
      var.health_check_grace_period_seconds <= 2147483647
    )

    error_message = "health_check_grace_period_seconds must be a valid ECS grace period."
  }
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of desired tasks kept healthy during a deployment."
  type        = number
  default     = 100

  validation {
    condition = (
      var.deployment_minimum_healthy_percent >= 0 &&
      var.deployment_minimum_healthy_percent <= 100
    )

    error_message = "deployment_minimum_healthy_percent must be between 0 and 100."
  }
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of desired tasks allowed during a deployment."
  type        = number
  default     = 200

  validation {
    condition = (
      var.deployment_maximum_percent >= 100 &&
      var.deployment_maximum_percent <= 200
    )

    error_message = "deployment_maximum_percent must be between 100 and 200."
  }
}

variable "wait_for_steady_state" {
  description = "Whether Terraform waits for the service to reach a steady state."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to the ECS service."
  type        = map(string)
  default     = {}
}
