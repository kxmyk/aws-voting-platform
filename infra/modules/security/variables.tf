variable "name" {
  description = "Name prefix used for security groups."
  type        = string

  validation {
    condition = (
      length(var.name) >= 3 &&
      length(var.name) <= 50 &&
      can(regex("^[a-z0-9-]+$", var.name))
    )

    error_message = "name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where security groups are created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-zA-Z0-9]+$", var.vpc_id))
    error_message = "vpc_id must be a valid AWS VPC ID."
  }
}

variable "alb_ingress_ipv4_cidrs" {
  description = "IPv4 CIDR blocks allowed to access the public load balancer."
  type        = list(string)

  default = [
    "0.0.0.0/0"
  ]

  validation {
    condition = (
      length(var.alb_ingress_ipv4_cidrs) > 0 &&
      alltrue([
        for cidr in var.alb_ingress_ipv4_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "alb_ingress_ipv4_cidrs must contain at least one valid IPv4 CIDR block."
  }
}

variable "enable_https_ingress" {
  description = "Whether HTTPS ingress is allowed to the load balancer."
  type        = bool
  default     = false
}

variable "http_port" {
  description = "HTTP listener port used by the public load balancer."
  type        = number
  default     = 80

  validation {
    condition     = var.http_port >= 1 && var.http_port <= 65535
    error_message = "http_port must be between 1 and 65535."
  }
}

variable "https_port" {
  description = "HTTPS listener port used by the public load balancer."
  type        = number
  default     = 443

  validation {
    condition     = var.https_port >= 1 && var.https_port <= 65535
    error_message = "https_port must be between 1 and 65535."
  }
}

variable "vote_port" {
  description = "Container port used by the vote application."
  type        = number
  default     = 80

  validation {
    condition     = var.vote_port >= 1 && var.vote_port <= 65535
    error_message = "vote_port must be between 1 and 65535."
  }
}

variable "result_port" {
  description = "Container port used by the result application."
  type        = number
  default     = 80

  validation {
    condition     = var.result_port >= 1 && var.result_port <= 65535
    error_message = "result_port must be between 1 and 65535."
  }
}

variable "redis_port" {
  description = "Port used by Redis."
  type        = number
  default     = 6379

  validation {
    condition     = var.redis_port >= 1 && var.redis_port <= 65535
    error_message = "redis_port must be between 1 and 65535."
  }
}

variable "postgres_port" {
  description = "Port used by PostgreSQL."
  type        = number
  default     = 5432

  validation {
    condition     = var.postgres_port >= 1 && var.postgres_port <= 65535
    error_message = "postgres_port must be between 1 and 65535."
  }
}

variable "application_https_egress_ipv4_cidr" {
  description = "IPv4 destination allowed for outbound HTTPS traffic from application tasks."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.application_https_egress_ipv4_cidr))
    error_message = "application_https_egress_ipv4_cidr must be a valid IPv4 CIDR block."
  }
}

variable "tags" {
  description = "Additional tags applied to security groups."
  type        = map(string)
  default     = {}
}
