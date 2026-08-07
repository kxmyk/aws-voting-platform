variable "name" {
  description = "Name prefix used for ElastiCache Redis resources."
  type        = string

  validation {
    condition = (
      length(var.name) >= 3 &&
      length(var.name) <= 34 &&
      can(regex("^[a-z0-9-]+$", var.name))
    )

    error_message = "name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the ElastiCache subnet group."
  type        = set(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "subnet_ids must contain at least two private subnets."
  }
}

variable "security_group_id" {
  description = "Security group ID assigned to Redis."
  type        = string

  validation {
    condition     = can(regex("^sg-[a-zA-Z0-9]+$", var.security_group_id))
    error_message = "security_group_id must be a valid security group ID."
  }
}

variable "engine_version" {
  description = "Redis OSS engine version."
  type        = string
  default     = "7.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.engine_version))
    error_message = "engine_version must use major.minor format, for example 7.1."
  }
}

variable "node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t4g.micro"

  validation {
    condition     = can(regex("^cache\\.[a-z0-9]+\\.[a-z0-9]+$", var.node_type))
    error_message = "node_type must be a valid ElastiCache node type."
  }
}

variable "port" {
  description = "Redis TCP port."
  type        = number
  default     = 6379

  validation {
    condition = (
      var.port >= 1024 &&
      var.port <= 65535
    )

    error_message = "port must be between 1024 and 65535."
  }
}

variable "snapshot_retention_limit" {
  description = "Number of days that ElastiCache snapshots are retained. Zero disables automatic snapshots."
  type        = number
  default     = 0

  validation {
    condition = (
      var.snapshot_retention_limit >= 0 &&
      var.snapshot_retention_limit <= 35
    )

    error_message = "snapshot_retention_limit must be between 0 and 35."
  }
}

variable "apply_immediately" {
  description = "Whether ElastiCache modifications are applied immediately."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to ElastiCache resources."
  type        = map(string)
  default     = {}
}
