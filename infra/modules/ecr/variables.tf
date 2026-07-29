variable "repository_prefix" {
  description = "Namespace added before each ECR repository name."
  type        = string

  validation {
    condition = (
      length(var.repository_prefix) >= 3 &&
      length(var.repository_prefix) <= 100 &&
      can(regex("^[a-z0-9]+(?:[._-][a-z0-9]+)*$", var.repository_prefix))
    )

    error_message = "repository_prefix must contain lowercase letters, numbers, periods, underscores, or hyphens."
  }
}

variable "service_names" {
  description = "Names of application services that require ECR repositories."
  type        = set(string)

  validation {
    condition = (
      length(var.service_names) > 0 &&
      alltrue([
        for service_name in var.service_names :
        can(regex("^[a-z0-9]+(?:[._-][a-z0-9]+)*$", service_name))
      ])
    )

    error_message = "service_names must contain valid lowercase ECR repository name components."
  }
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      ["MUTABLE", "IMMUTABLE"],
      var.image_tag_mutability
    )

    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Whether ECR performs basic vulnerability scanning after an image is pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Server-side encryption type used by ECR repositories."
  type        = string
  default     = "AES256"

  validation {
    condition = contains(
      ["AES256", "KMS"],
      var.encryption_type
    )

    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "force_delete" {
  description = "Whether repositories can be deleted while they still contain images."
  type        = bool
  default     = false
}

variable "untagged_image_expiration_days" {
  description = "Number of days after which untagged images are removed."
  type        = number
  default     = 1

  validation {
    condition     = var.untagged_image_expiration_days >= 1
    error_message = "untagged_image_expiration_days must be at least 1."
  }
}

variable "max_image_count" {
  description = "Maximum number of images retained in each repository."
  type        = number
  default     = 15

  validation {
    condition     = var.max_image_count >= 3
    error_message = "max_image_count must be at least 3."
  }
}

variable "tags" {
  description = "Additional tags applied to ECR repositories."
  type        = map(string)
  default     = {}
}
