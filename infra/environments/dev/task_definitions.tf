data "aws_ecr_image" "service" {
  for_each = var.ecs_service_names

  repository_name = "${var.project_name}/${each.key}"
  image_tag       = var.ecs_bootstrap_image_tag
}

locals {
  postgres_password_secret = join("", [
    module.postgres.master_user_secret_arn,
    ":password::"
  ])

  ecs_task_configuration = {
    vote = {
      container_port = 80

      environment = {
        OPTION_A             = "Cats"
        OPTION_B             = "Dogs"
        REDIS_HOST           = module.redis.primary_endpoint_address
        REDIS_PORT           = tostring(module.redis.port)
        REDIS_DB             = "0"
        REDIS_SOCKET_TIMEOUT = "5"
        REDIS_TLS            = "true"
      }

      secrets = {}
    }

    result = {
      container_port = 80

      environment = {
        DB_HOST = module.postgres.address
        DB_PORT = tostring(module.postgres.port)
        DB_NAME = module.postgres.database_name
        DB_USER = module.postgres.master_username
        DB_SSL  = "true"
      }

      secrets = {
        DB_PASSWORD = local.postgres_password_secret
      }
    }

    worker = {
      container_port = null

      environment = {
        REDIS_HOST = module.redis.primary_endpoint_address
        REDIS_PORT = tostring(module.redis.port)
        REDIS_TLS  = "true"

        DB_HOST = module.postgres.address
        DB_PORT = tostring(module.postgres.port)
        DB_NAME = module.postgres.database_name
        DB_USER = module.postgres.master_username
      }

      secrets = {
        DB_PASSWORD = local.postgres_password_secret
      }
    }
  }
}

resource "aws_ecs_task_definition" "service" {
  for_each = local.ecs_task_configuration

  family = join("-", [
    var.project_name,
    var.environment,
    each.key
  ])

  requires_compatibilities = [
    "FARGATE"
  ]

  network_mode = "awsvpc"

  cpu    = tostring(var.ecs_task_cpu)
  memory = tostring(var.ecs_task_memory)

  execution_role_arn = module.ecs.task_execution_role_arn
  task_role_arn      = module.ecs.task_role_arns[each.key]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    merge(
      {
        name      = each.key
        image     = data.aws_ecr_image.service[each.key].image_uri
        essential = true

        environment = [
          for environment_name, environment_value
          in each.value.environment : {
            name  = environment_name
            value = environment_value
          }
        ]

        secrets = [
          for secret_name, secret_value_from
          in each.value.secrets : {
            name      = secret_name
            valueFrom = secret_value_from
          }
        ]

        logConfiguration = {
          logDriver = "awslogs"

          options = {
            awslogs-group         = module.ecs.log_group_names[each.key]
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }
      },

      each.value.container_port == null
      ? {}
      : {
        portMappings = [
          {
            containerPort = each.value.container_port
            hostPort      = each.value.container_port
            protocol      = "tcp"
          }
        ]
      }
    )
  ])

  track_latest = false

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-${var.environment}-${each.key}"
    Service = each.key
  })
}
