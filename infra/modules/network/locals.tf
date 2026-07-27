locals {
  availability_zone_set = toset(var.availability_zones)

  public_subnets = {
    for index, availability_zone in var.availability_zones :
    availability_zone => {
      cidr_block = var.public_subnet_cidrs[index]
      index      = index
    }
  }

  private_app_subnets = {
    for index, availability_zone in var.availability_zones :
    availability_zone => {
      cidr_block = var.private_app_subnet_cidrs[index]
      index      = index
    }
  }

  private_data_subnets = {
    for index, availability_zone in var.availability_zones :
    availability_zone => {
      cidr_block = var.private_data_subnet_cidrs[index]
      index      = index
    }
  }

  nat_gateway_availability_zones = (
    var.nat_gateway_mode == "none"
    ? toset([])
    : var.nat_gateway_mode == "single"
    ? toset([var.availability_zones[0]])
    : local.availability_zone_set
  )
}
