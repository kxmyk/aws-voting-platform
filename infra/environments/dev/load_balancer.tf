locals {
  alb_target_groups = {
    vote = {
      port                 = 80
      protocol             = "HTTP"
      health_check_path    = "/ready"
      health_check_matcher = "200"
      deregistration_delay = 30
    }

    result = {
      port                 = 80
      protocol             = "HTTP"
      health_check_path    = "/ready"
      health_check_matcher = "200"
      deregistration_delay = 30
    }
  }

  alb_listener_rules = {
    results = {
      priority         = 10
      path_patterns    = ["/results", "/results/*"]
      target_group_key = "result"

      url_rewrite = {
        regex   = "^/results/?(.*)$"
        replace = "/$1"
      }
    }

    result_assets = {
      priority = 20

      path_patterns = [
        "/stylesheets/*",
        "/app.js",
        "/angular.min.js",
        "/socket.io.js"
      ]

      target_group_key = "result"
      url_rewrite      = null
    }

    result_socket = {
      priority         = 30
      path_patterns    = ["/socket.io/*"]
      target_group_key = "result"
      url_rewrite      = null
    }
  }
}

module "alb" {
  source = "../../modules/alb"

  name   = "${var.project_name}-${var.environment}"
  vpc_id = module.network.vpc_id

  subnet_ids = toset(
    values(module.network.public_subnet_ids)
  )

  security_group_ids = toset([
    module.security.alb_security_group_id
  ])

  target_groups            = local.alb_target_groups
  default_target_group_key = "vote"
  listener_port            = 80
  listener_rules           = local.alb_listener_rules

  tags = local.common_tags
}
