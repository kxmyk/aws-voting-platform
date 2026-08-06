variable "postgres_engine_major_version" {
  description = "Preferred PostgreSQL major version."
  type        = string
  default     = "16"

  validation {
    condition     = can(regex("^[0-9]+$", var.postgres_engine_major_version))
    error_message = "postgres_engine_major_version must contain only the major version number."
  }
}

variable "postgres_instance_class" {
  description = "RDS PostgreSQL instance class used in development."
  type        = string
  default     = "db.t4g.micro"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.postgres_instance_class))
    error_message = "postgres_instance_class must be a valid RDS instance class."
  }
}

variable "postgres_allocated_storage" {
  description = "Allocated PostgreSQL storage in GiB."
  type        = number
  default     = 20

  validation {
    condition = (
      var.postgres_allocated_storage >= 20 &&
      var.postgres_allocated_storage <= 100
    )

    error_message = "postgres_allocated_storage must be between 20 and 100 GiB."
  }
}

variable "postgres_database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "voting"

  validation {
    condition = (
      length(var.postgres_database_name) >= 1 &&
      length(var.postgres_database_name) <= 63 &&
      can(regex("^[A-Za-z][A-Za-z0-9]*$", var.postgres_database_name))
    )

    error_message = "postgres_database_name must begin with a letter and contain only letters and numbers."
  }
}

variable "postgres_master_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "dbadmin"

  validation {
    condition = (
      length(var.postgres_master_username) >= 1 &&
      length(var.postgres_master_username) <= 63 &&
      can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.postgres_master_username))
    )

    error_message = "postgres_master_username must begin with a letter and contain only letters, numbers, and underscores."
  }
}

variable "postgres_backup_retention_days" {
  description = "Number of days that automated PostgreSQL backups are retained."
  type        = number
  default     = 1

  validation {
    condition = (
      var.postgres_backup_retention_days >= 0 &&
      var.postgres_backup_retention_days <= 35
    )

    error_message = "postgres_backup_retention_days must be between 0 and 35."
  }
}

variable "postgres_multi_az" {
  description = "Whether PostgreSQL uses an RDS Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "postgres_deletion_protection" {
  description = "Whether deletion protection is enabled for PostgreSQL."
  type        = bool
  default     = false
}

variable "postgres_skip_final_snapshot" {
  description = "Whether the development database skips a final snapshot during deletion."
  type        = bool
  default     = true
}
