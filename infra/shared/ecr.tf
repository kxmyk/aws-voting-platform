module "ecr" {
  source = "../modules/ecr"

  repository_prefix = var.project_name
  service_names     = var.service_names

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"
  force_delete         = false

  untagged_image_expiration_days = var.untagged_image_expiration_days
  max_image_count                = var.max_ecr_image_count

  tags = local.common_tags
}
