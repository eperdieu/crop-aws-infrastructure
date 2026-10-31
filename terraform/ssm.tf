# =================== Preconfigured SSM Parameters ===================

data "aws_ssm_parameter" "openai_api_key" {
  name = var.openai_api_key_parameter_name
}

data "aws_ssm_parameter" "recaptcha_secret" {
  name = var.recaptcha_secret_parameter_name
}

data "aws_ssm_parameter" "recaptcha_site_key" {
  name = var.recaptcha_site_key_parameter_name
}

data "aws_ssm_parameter" "sendgrid_api_key" {
  name = var.sendgrid_api_key_parameter_name
}

data "aws_ssm_parameter" "sendgrid_from_email" {
  name = var.sendgrid_from_email_parameter_name
}

data "aws_ssm_parameter" "ga4_measurement_id" {
  name = var.ga4_measurement_id_parameter_name
}

# =================== Preconfigured SSM Parameters ===================



# =================== ECS Configuration Parameters for Apply Schema Workflow ===================

resource "aws_ssm_parameter" "ecs_cluster_name" {
  name  = "/isa/${local.environment}/ecs_cluster_name"
  type  = "String"
  value = aws_ecs_cluster.main.name
  
  tags = {
    Name        = "ecs-cluster-name-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ssm_parameter" "ecs_task_definition_family" {
  name  = "/isa/${local.environment}/ecs_task_definition"
  type  = "String"
  value = aws_ecs_task_definition.backend.family
  
  tags = {
    Name        = "ecs-task-definition-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ssm_parameter" "private_subnet_1_id" {
  name  = "/isa/${local.environment}/private_subnet_1"
  type  = "String"
  value = aws_subnet.private_1.id
  
  tags = {
    Name        = "private-subnet-1-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ssm_parameter" "private_subnet_2_id" {
  name  = "/isa/${local.environment}/private_subnet_2"
  type  = "String"
  value = aws_subnet.private_2.id
  
  tags = {
    Name        = "private-subnet-2-${local.environment}"
    Environment = local.environment
  }
}

# Security Group ID parameters for different services
resource "aws_ssm_parameter" "node_server_sg_id" {
  name  = "/isa/${local.environment}/node_server_sg_id"
  type  = "String"
  value = aws_security_group.node_server.id
  
  tags = {
    Name        = "node-server-sg-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ssm_parameter" "scraping_service_sg_id" {
  name  = "/isa/${local.environment}/scraping_service_sg_id"
  type  = "String"
  value = aws_security_group.scraping_service.id
  
  tags = {
    Name        = "scraping-service-sg-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ssm_parameter" "ssurgo_service_sg_id" {
  name  = "/isa/${local.environment}/ssurgo_service_sg_id"
  type  = "String"
  value = aws_security_group.ssurgo_service.id
  
  tags = {
    Name        = "ssurgo-service-sg-${local.environment}"
    Environment = local.environment
  }
}

# =================== Admin Credential Secret ARNs ===================
# Stored so the create_admin workflow can look them up without hardcoding names

resource "aws_ssm_parameter" "admin_username_secret_arn" {
  name  = "/isa/${local.environment}/admin_username_secret_arn"
  type  = "String"
  value = aws_secretsmanager_secret.admin_username_secret.arn

  tags = {
    Name        = "admin-username-secret-arn-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_ssm_parameter" "admin_password_secret_arn" {
  name  = "/isa/${local.environment}/admin_password_secret_arn"
  type  = "String"
  value = aws_secretsmanager_secret.admin_password_secret.arn

  tags = {
    Name        = "admin-password-secret-arn-${local.environment}"
    Environment = local.environment
  }
}

# =================== Admin Credential Secret ARNs ===================

# =================== ECS Configuration Parameters for Apply Schema Workflow ===================