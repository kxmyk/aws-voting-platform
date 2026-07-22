variable "aws_region" {
  description = "AWS region used by the project."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region name, for example eu-central-1."
  }
}

variable "project_name" {
  description = "Name used to identify and tag project resources."
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
