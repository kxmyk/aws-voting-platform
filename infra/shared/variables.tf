variable "aws_region" {
  description = "AWS region used by shared project infrastructure."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region name."
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

variable "service_names" {
  description = "Application services that require private ECR repositories."
  type        = set(string)

  default = [
    "vote",
    "result",
    "worker"
  ]
}

variable "max_ecr_image_count" {
  description = "Maximum number of images retained in each ECR repository."
  type        = number
  default     = 15

  validation {
    condition     = var.max_ecr_image_count >= 3
    error_message = "max_ecr_image_count must be at least 3."
  }
}

variable "untagged_image_expiration_days" {
  description = "Number of days after which untagged ECR images are removed."
  type        = number
  default     = 1

  validation {
    condition     = var.untagged_image_expiration_days >= 1
    error_message = "untagged_image_expiration_days must be at least 1."
  }
}

variable "github_owner" {
  description = "GitHub account or organization that owns the repository."
  type        = string
  default     = "kxmyk"

  validation {
    condition = (
      length(var.github_owner) >= 1 &&
      length(var.github_owner) <= 100 &&
      can(regex("^[A-Za-z0-9-]+$", var.github_owner))
    )

    error_message = "github_owner must contain only letters, numbers, and hyphens."
  }
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the AWS IAM role."
  type        = string
  default     = "aws-voting-platform"

  validation {
    condition = (
      length(var.github_repository) >= 1 &&
      length(var.github_repository) <= 100 &&
      can(regex("^[A-Za-z0-9_.-]+$", var.github_repository))
    )

    error_message = "github_repository contains unsupported characters."
  }
}

variable "github_deployment_branch" {
  description = "GitHub branch allowed to publish images to ECR."
  type        = string
  default     = "main"

  validation {
    condition = (
      length(var.github_deployment_branch) >= 1 &&
      length(var.github_deployment_branch) <= 255 &&
      can(regex("^[A-Za-z0-9._/-]+$", var.github_deployment_branch))
    )

    error_message = "github_deployment_branch contains unsupported characters."
  }
}
