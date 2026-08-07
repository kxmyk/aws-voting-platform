variable "redis_engine_version" {
  description = "Redis OSS engine version used by ElastiCache."
  type        = string
  default     = "7.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.redis_engine_version))
    error_message = "redis_engine_version must use major.minor format."
  }
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type used in development."
  type        = string
  default     = "cache.t4g.micro"

  validation {
    condition     = can(regex("^cache\\.[a-z0-9]+\\.[a-z0-9]+$", var.redis_node_type))
    error_message = "redis_node_type must be a valid ElastiCache node type."
  }
}

variable "redis_snapshot_retention_limit" {
  description = "Number of days that Redis automatic snapshots are retained."
  type        = number
  default     = 0

  validation {
    condition = (
      var.redis_snapshot_retention_limit >= 0 &&
      var.redis_snapshot_retention_limit <= 35
    )

    error_message = "redis_snapshot_retention_limit must be between 0 and 35."
  }
}
