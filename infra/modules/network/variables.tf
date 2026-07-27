variable "name" {
  description = "Name prefix used for networking resources."
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

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Two availability zones used by the network."
  type        = list(string)

  validation {
    condition = (
      length(var.availability_zones) == 2 &&
      length(distinct(var.availability_zones)) == 2
    )

    error_message = "availability_zones must contain exactly two unique availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the public subnets."
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) == 2 &&
      alltrue([
        for cidr in var.public_subnet_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "public_subnet_cidrs must contain exactly two valid IPv4 CIDR blocks."
  }
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks assigned to the private application subnets."
  type        = list(string)

  validation {
    condition = (
      length(var.private_app_subnet_cidrs) == 2 &&
      alltrue([
        for cidr in var.private_app_subnet_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "private_app_subnet_cidrs must contain exactly two valid IPv4 CIDR blocks."
  }
}

variable "private_data_subnet_cidrs" {
  description = "CIDR blocks assigned to the private data subnets."
  type        = list(string)

  validation {
    condition = (
      length(var.private_data_subnet_cidrs) == 2 &&
      alltrue([
        for cidr in var.private_data_subnet_cidrs :
        can(cidrnetmask(cidr))
      ])
    )

    error_message = "private_data_subnet_cidrs must contain exactly two valid IPv4 CIDR blocks."
  }
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

variable "tags" {
  description = "Additional tags applied to networking resources."
  type        = map(string)
  default     = {}
}
