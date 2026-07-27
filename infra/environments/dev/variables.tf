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

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the development VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to public subnets."
  type        = list(string)

  default = [
    "10.20.0.0/24",
    "10.20.1.0/24"
  ]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks assigned to private application subnets."
  type        = list(string)

  default = [
    "10.20.10.0/24",
    "10.20.11.0/24"
  ]
}

variable "private_data_subnet_cidrs" {
  description = "CIDR blocks assigned to private data subnets."
  type        = list(string)

  default = [
    "10.20.20.0/24",
    "10.20.21.0/24"
  ]
}

variable "nat_gateway_mode" {
  description = "NAT Gateway deployment mode: none, single, or per_az."
  type        = string
  default     = "single"

  validation {
    condition = contains(
      ["none", "single", "per_az"],
      var.nat_gateway_mode
    )

    error_message = "nat_gateway_mode must be one of: none, single, per_az."
  }
}
