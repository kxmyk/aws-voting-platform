output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the network."
  value       = var.availability_zones
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs indexed by availability zone."
  value = {
    for availability_zone, subnet in aws_subnet.public :
    availability_zone => subnet.id
  }
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs indexed by availability zone."
  value = {
    for availability_zone, subnet in aws_subnet.private_app :
    availability_zone => subnet.id
  }
}

output "private_data_subnet_ids" {
  description = "Private data subnet IDs indexed by availability zone."
  value = {
    for availability_zone, subnet in aws_subnet.private_data :
    availability_zone => subnet.id
  }
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "Private application route table IDs indexed by availability zone."
  value = {
    for availability_zone, route_table in aws_route_table.private_app :
    availability_zone => route_table.id
  }
}

output "private_data_route_table_ids" {
  description = "Private data route table IDs indexed by availability zone."
  value = {
    for availability_zone, route_table in aws_route_table.private_data :
    availability_zone => route_table.id
  }
}

output "nat_gateway_mode" {
  description = "Configured NAT Gateway deployment mode."
  value       = var.nat_gateway_mode
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs indexed by availability zone."
  value = {
    for availability_zone, nat_gateway in aws_nat_gateway.this :
    availability_zone => nat_gateway.id
  }
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses assigned to NAT Gateways."
  value = {
    for availability_zone, elastic_ip in aws_eip.nat :
    availability_zone => elastic_ip.public_ip
  }
}
