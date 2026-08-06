variable "name" {
  description = "Name prefix used for PostgreSQL resources."
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

variable "subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group."
  type        = set(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "subnet_ids must contain at least two private subnets."
  }
}

variable "security_group_id" {
  description = "Security group ID assigned to the PostgreSQL DB instance."
  type        = string

  validation {
    condition     = can(regex("^sg-[a-zA-Z0-9]+$", var.security_group_id))
    error_message = "security_group_id must be a valid security group ID."
  }
}

variable "engine_version" {
  description = "Exact PostgreSQL engine version selected for the current AWS region."
  type        = string

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)*$", var.engine_version))
    error_message = "engine_version must be a valid PostgreSQL version."
  }
}

variable "instance_class" {
  description = "RDS DB instance class."
  type        = string
  default     = "db.t4g.micro"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.instance_class))
    error_message = "instance_class must be a valid RDS instance class."
  }
}

variable "allocated_storage" {
  description = "Allocated PostgreSQL storage in GiB."
  type        = number
  default     = 20

  validation {
    condition = (
      var.allocated_storage >= 20 &&
      var.allocated_storage <= 100
    )

    error_message = "allocated_storage must be between 20 and 100 GiB."
  }
}

variable "database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "voting"

  validation {
    condition = (
      length(var.database_name) >= 1 &&
      length(var.database_name) <= 63 &&
      can(regex("^[A-Za-z][A-Za-z0-9]*$", var.database_name))
    )

    error_message = "database_name must begin with a letter and contain only letters and numbers."
  }
}

variable "master_username" {
  description = "PostgreSQL master username. The password is managed by RDS in Secrets Manager."
  type        = string
  default     = "dbadmin"

  validation {
    condition = (
      length(var.master_username) >= 1 &&
      length(var.master_username) <= 63 &&
      can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.master_username))
    )

    error_message = "master_username must begin with a letter and contain only letters, numbers, and underscores."
  }
}

variable "backup_retention_days" {
  description = "Number of days that automated RDS backups are retained."
  type        = number
  default     = 1

  validation {
    condition = (
      var.backup_retention_days >= 0 &&
      var.backup_retention_days <= 35
    )

    error_message = "backup_retention_days must be between 0 and 35."
  }
}

variable "multi_az" {
  description = "Whether the PostgreSQL instance uses an RDS Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the DB instance."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether RDS skips creating a final snapshot during deletion."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether RDS configuration changes are applied immediately."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to PostgreSQL resources."
  type        = map(string)
  default     = {}
}
