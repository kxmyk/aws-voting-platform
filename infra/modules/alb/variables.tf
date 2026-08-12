variable "name" {
  description = "Name prefix used for Application Load Balancer resources."
  type        = string

  validation {
    condition = (
      length(var.name) >= 3 &&
      length(var.name) <= 24 &&
      can(regex("^[a-z0-9-]+$", var.name))
    )

    error_message = "name must contain only lowercase letters, numbers, and hyphens and be at most 24 characters."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where target groups are created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-zA-Z0-9]+$", var.vpc_id))
    error_message = "vpc_id must be a valid AWS VPC ID."
  }
}

variable "subnet_ids" {
  description = "Public subnet IDs used by the internet-facing load balancer."
  type        = set(string)

  validation {
    condition = (
      length(var.subnet_ids) >= 2 &&
      alltrue([
        for subnet_id in var.subnet_ids :
        can(regex("^subnet-[a-zA-Z0-9]+$", subnet_id))
      ])
    )

    error_message = "subnet_ids must contain at least two valid subnet IDs."
  }
}

variable "security_group_ids" {
  description = "Security group IDs attached to the load balancer."
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

variable "target_groups" {
  description = "Target group definitions indexed by application service name."

  type = map(object({
    port                 = number
    protocol             = optional(string, "HTTP")
    health_check_path    = string
    health_check_matcher = optional(string, "200-399")
    deregistration_delay = optional(number, 30)
  }))

  validation {
    condition = (
      length(var.target_groups) > 0 &&
      length(distinct([
        for target_group_name in keys(var.target_groups) :
        substr(target_group_name, 0, 4)
      ])) == length(var.target_groups) &&
      alltrue([
        for target_group_name, target_group in var.target_groups :
        length(target_group_name) >= 1 &&
        length(target_group_name) <= 12 &&
        can(regex("^[a-z0-9-]+$", target_group_name)) &&
        target_group.port >= 1 &&
        target_group.port <= 65535 &&
        contains(["HTTP", "HTTPS"], target_group.protocol) &&
        startswith(target_group.health_check_path, "/") &&
        target_group.deregistration_delay >= 0 &&
        target_group.deregistration_delay <= 3600
      ])
    )

    error_message = "target_groups must have unique four-character prefixes and contain valid names, ports, protocols, health check paths, and deregistration delays."
  }
}

variable "default_target_group_key" {
  description = "Key of the target group used by the listener default action."
  type        = string

  validation {
    condition     = contains(keys(var.target_groups), var.default_target_group_key)
    error_message = "default_target_group_key must identify a configured target group."
  }
}

variable "listener_port" {
  description = "Port used by the public HTTP listener."
  type        = number
  default     = 80

  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535
    error_message = "listener_port must be between 1 and 65535."
  }
}

variable "listener_rules" {
  description = "Path-based listener rules indexed by a stable rule name."

  type = map(object({
    priority         = number
    path_patterns    = list(string)
    target_group_key = string
    url_rewrite = optional(object({
      regex   = string
      replace = string
    }))
  }))

  default = {}

  validation {
    condition = (
      length(distinct([
        for listener_rule in values(var.listener_rules) :
        listener_rule.priority
      ])) == length(var.listener_rules) &&
      alltrue([
        for listener_rule in values(var.listener_rules) :
        listener_rule.priority >= 1 &&
        listener_rule.priority <= 50000 &&
        length(listener_rule.path_patterns) >= 1 &&
        length(listener_rule.path_patterns) <= 5 &&
        alltrue([
          for path_pattern in listener_rule.path_patterns :
          startswith(path_pattern, "/")
        ]) &&
        contains(keys(var.target_groups), listener_rule.target_group_key)
      ])
    )

    error_message = "listener_rules must use unique priorities, one to five absolute path patterns, and configured target groups."
  }
}

variable "tags" {
  description = "Additional tags applied to load balancer resources."
  type        = map(string)
  default     = {}
}
