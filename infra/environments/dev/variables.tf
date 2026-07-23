variable "aws_region" {
  description = "AWS region used by the development environment."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region name, for example eu-central-1."
  }
}

variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
  default     = "aws-voting-platform"

  validation {
    condition = (
      length(var.project_name) >= 3 &&
      length(var.project_name) <= 40 &&
      can(regex("^[a-z0-9-]+$", var.project_name))
    )

    error_message = "project_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
