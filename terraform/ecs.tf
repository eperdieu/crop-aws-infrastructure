# ===================== ECS Cluster ===================== 

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster-${local.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.app_name}-cluster-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }
}

# ===================== ECS Cluster =====================



# =================== Backend ECS Task Definition =================== 

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.app_name}-${local.environment}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"  # Required for Fargate
  cpu                      = "256"
  memory                   = "1024"
  
  # TODO: Update IAM role to be more specific with permissions?
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  # EFS Volume definitions matching docker-compose volumes
  volume {
    name = "upload-files" 
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.upload_files.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.upload_files.id
        iam             = "ENABLED"
      }
    }
  }

  # Multi-container definition matching docker-compose services
  container_definitions = jsonencode([
    # Backend Node.js service
    {
      name = "backend"
      image = "${aws_ecr_repository.app.repository_url}:backend-latest"
      essential = true
      
      cpu = 256
      memory = 1024

      portMappings = [
        {
          containerPort = 5001
          protocol = "tcp"
        }
      ]

      # Mount shared volumes
      mountPoints = [
        {
          sourceVolume  = "upload-files"
          containerPath = "/tmp/field_boundary_uploads"
          readOnly      = false
        }
      ]

      # Environment variables
      environment = [
        {
          name  = "NODE_ENV"
          value = local.environment
        },
        {
          name  = "PORT"
          value = "5001"
        },
        {
          name  = "SERVER_URL"
          value = local.api_url
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          name = "DB_USER"
          value = aws_db_instance.postgres.username
        },
        {
          name  = "FRONTEND_URL"
          value = local.website_url
        },
        {
          name  = "SENDGRID_FROM_EMAIL"
          value = data.aws_ssm_parameter.sendgrid_from_email.value
        },
        {
          name  = "SCRAPING_SERVICE_URL"
          value = "http://scraper:8001"
        },
        {
          name  = "SSURGO_SERVICE_URL"
          value = "http://ssurgo:8000"
        },
        {
          name  = "DOCKER_CONTAINER"
          value = "1"
        }
      ]
    
      # Sensitive values from AWS Secrets Manager (fetched at runtime)
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_secretsmanager_secret_version.db_password_secret_version.arn
        },
        {
          name      = "FARMER_ACCESS_TOKEN_SECRET"
          valueFrom = aws_secretsmanager_secret_version.farmer_access_token_secret_version.arn
        },
        {
          name      = "FARMER_REFRESH_TOKEN_SECRET"
          valueFrom = aws_secretsmanager_secret_version.farmer_refresh_token_secret_version.arn
        },
        {
          name      = "PASSWORD_RESET_TOKEN_SECRET"
          valueFrom = aws_secretsmanager_secret_version.password_reset_token_secret_version.arn
        },
        {
          name      = "ADMIN_ACCESS_TOKEN_SECRET"
          valueFrom = aws_secretsmanager_secret_version.admin_access_token_secret_version.arn
        },
        {
          name      = "ADMIN_REFRESH_TOKEN_SECRET"
          valueFrom = aws_secretsmanager_secret_version.admin_refresh_token_secret_version.arn
        },
        {
          name      = "OPENAI_API_KEY"
          valueFrom = data.aws_ssm_parameter.openai_api_key.arn
        },
        {
          name      = "RECAPTCHA_SECRET_KEY"
          valueFrom = data.aws_ssm_parameter.recaptcha_secret.arn
        },
        {
          name      = "SENDGRID_API_KEY"
          valueFrom = data.aws_ssm_parameter.sendgrid_api_key.arn
        },
        {
          name      = "VITE_RECAPTCHA_SITE_KEY"
          valueFrom = data.aws_ssm_parameter.recaptcha_site_key.arn
        }
      ]

      # CloudWatch logging
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.app_name}-${local.environment}-backend-task"
    Environment = local.environment
  }
}

# =================== Backend ECS Task Definition =================== 



# =================== Scraper ECS Task Definition =================== 
resource "aws_ecs_task_definition" "scraper" {
  family                   = "${var.app_name}-${local.environment}-scraper"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "2048"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    # Scraping Service
    {
      name = "scraper"
      image = "${aws_ecr_repository.app.repository_url}:scraper-latest"
      essential = true

      cpu = 256
      memory = 1024

      portMappings = [
        {
          containerPort = 8001
          protocol      = "tcp"
          name          = "scraper-port"
        }
      ]

      mountPoints = []

      # Environment variables
      environment = [
        {
          name  = "DOCKER_CONTAINER"
          value = "1"
        },
        {
          name  = "SCRAPING_SERVICE_PORT"
          value = "8001"
        },
        {
          name  = "SCRAPING_QUEUE_URL"
          value = aws_sqs_queue.scraping_jobs.url
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "SELENIUM_URL"
          value = "http://localhost:4444"
        }
      ]
      secrets = [
        {
          name      = "OPENAI_API_KEY"
          valueFrom = data.aws_ssm_parameter.openai_api_key.arn
        }
      ]

      # CloudWatch logging
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },

    # Selenium WebDriver (Chrome sidecar)
    {
      name      = "selenium"
      image     = "selenium/standalone-chrome:145.0.7632.116-chromedriver-145.0.7632.117-grid-4.41.0-20260222"
      essential = true

      cpu    = 256
      memory = 1024

      portMappings = [
        {
          containerPort = 4444
          protocol      = "tcp"
        }
      ]

      mountPoints = []

      environment = [
        {
          name  = "SE_SESSION_TIMEOUT"
          value = "300"
        },
        {
          name  = "SE_NODE_SESSION_TIMEOUT"
          value = "300"
        }
      ]

      # CloudWatch logging
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.app_name}-${local.environment}-scraper-task"
    Environment = local.environment
  }
}

# =================== Scraper ECS Task Definition =================== 



# =================== SSURGO ECS Task Definition =================== 

resource "aws_ecs_task_definition" "ssurgo" {
  family                   = "${var.app_name}-${local.environment}-ssurgo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  # EFS Volume definitions matching docker-compose volumes
  volume {
    name = "upload-files"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.upload_files.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.upload_files.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    # SSURGO Soil Data Service  
    {
      name = "ssurgo"
      image = "${aws_ecr_repository.app.repository_url}:ssurgo-latest"
      essential = true

      cpu = 256
      memory = 1024

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
          name          = "ssurgo-port"
        }
      ]

      # Mount shared volumes
      mountPoints = [
        {
          sourceVolume  = "upload-files"
          containerPath = "/tmp/field_boundary_uploads"
          readOnly      = false
        }
      ]

      # Environment variables
      environment = [
        {
          name  = "SSURGO_SERVICE_PORT"
          value = "8000"
        },
        {
          name  = "DOCKER_CONTAINER"
          value = "1"
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres.db_name
        },
        {
          name = "DB_USER"
          value = aws_db_instance.postgres.username
        }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_secretsmanager_secret_version.db_password_secret_version.arn
        },
        {
          name      = "OPENAI_API_KEY"
          valueFrom = data.aws_ssm_parameter.openai_api_key.arn
        }
      ]

      # CloudWatch logging
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.app_name}-${local.environment}-ssurgo-task"
    Environment = local.environment
  }
}

# =================== Scraper ECS Task Definition =================== 



# ======================= ECS Services =======================

resource "aws_service_discovery_http_namespace" "main" {
  name        = "${var.app_name}-${local.environment}"
  description = "Service Connect namespace for inter-service communication"

  tags = {
    Name        = "${var.app_name}-namespace-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ecs_service" "backend" {
  name            = "${var.app_name}-service-${local.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Allow destruction even with running tasks
  wait_for_steady_state = false
  force_new_deployment  = true

  # Backend stays in private subnet with NAT gateway access
  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.node_server.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "backend"
    container_port   = 5001
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.main.arn
  }

  depends_on = [
    aws_lb_listener.https,
    aws_cloudwatch_log_group.app,
    aws_ecs_service.scraper,
    aws_ecs_service.ssurgo,
  ]

  # Ignore changes to desired_count to allow external scaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Name        = "${var.app_name}-service-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ecs_service" "scraper" {
  name            = "${var.app_name}-scraper-service-${local.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.scraper.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  wait_for_steady_state = false
  force_new_deployment  = true

  # COST OPTIMIZATION: Scraper moved to public subnet to avoid NAT Gateway charges
  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.scraping_service.id]
    assign_public_ip = true  # Required for public subnet internet access
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.main.arn

    service {
      port_name      = "scraper-port"
      discovery_name = "scraper"

      client_alias {
        dns_name = "scraper"
        port     = 8001
      }
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.app,
    aws_service_discovery_http_namespace.main,
  ]

  # Ignore changes to desired_count to allow external scaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Name        = "${var.app_name}-scraper-service-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ecs_service" "ssurgo" {
  name            = "${var.app_name}-ssurgo-service-${local.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ssurgo.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  wait_for_steady_state = false
  force_new_deployment  = true

  # SECURITY: SSURGO stays in private subnet (handles sensitive farm data & DB access)
  # COST: API calls are lightweight, NAT Gateway cost minimal vs. security benefit
  network_configuration {
    subnets          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_groups  = [aws_security_group.ssurgo_service.id]
    assign_public_ip = false  # Private subnet with NAT Gateway access
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.main.arn

    service {
      port_name      = "ssurgo-port"
      discovery_name = "ssurgo"

      client_alias {
        dns_name = "ssurgo"
        port     = 8000
      }
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.app,
    aws_service_discovery_http_namespace.main,
  ]

  # Ignore changes to desired_count to allow external scaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Name        = "${var.app_name}-ssurgo-service-${local.environment}"
    Environment = local.environment
  }
}

# ======================= ECS Service =======================
