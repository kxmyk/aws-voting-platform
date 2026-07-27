data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  network_availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )
}

module "network" {
  source = "../../modules/network"

  name               = "${var.project_name}-${var.environment}"
  vpc_cidr           = var.vpc_cidr
  availability_zones = local.network_availability_zones

  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs

  nat_gateway_mode = var.nat_gateway_mode

  tags = local.common_tags
}
