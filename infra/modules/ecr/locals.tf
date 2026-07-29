locals {
  repositories = {
    for service_name in var.service_names :
    service_name => "${var.repository_prefix}/${service_name}"
  }
}
