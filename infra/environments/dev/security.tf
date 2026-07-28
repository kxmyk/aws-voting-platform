module "security" {
  source = "../../modules/security"

  name   = "${var.project_name}-${var.environment}"
  vpc_id = module.network.vpc_id

  alb_ingress_ipv4_cidrs = var.alb_ingress_ipv4_cidrs
  enable_https_ingress   = var.enable_https_ingress

  http_port     = 80
  https_port    = 443
  vote_port     = 80
  result_port   = 80
  redis_port    = 6379
  postgres_port = 5432

  tags = local.common_tags
}
