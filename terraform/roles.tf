# =================== ECS Task Execution Role ===================

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role-${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.app_name}-ecs-execution-role"
    Environment = local.environment
  }
}

# =================== ECS Task Execution Role ===================



# ==================== ECS Task Execution Role Policies ===================

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow reading secrets from Secrets Manager and Parameter Store
resource "aws_iam_role_policy" "secrets_access" {
  name = "secrets-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          aws_secretsmanager_secret.db_username_secret.arn,
          aws_secretsmanager_secret.db_password_secret.arn,
          aws_secretsmanager_secret.farmer_access_token_secret.arn,
          aws_secretsmanager_secret.farmer_refresh_token_secret.arn,
          aws_secretsmanager_secret.password_reset_token_secret.arn,
          aws_secretsmanager_secret.admin_access_token_secret.arn,
          aws_secretsmanager_secret.admin_refresh_token_secret.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:ssm:us-east-1:495117181746:parameter${var.openai_api_key_parameter_name}",
          "arn:aws:ssm:us-east-1:495117181746:parameter${var.recaptcha_secret_parameter_name}",
          "arn:aws:ssm:us-east-1:495117181746:parameter${var.sendgrid_api_key_parameter_name}",
          "arn:aws:ssm:us-east-1:495117181746:parameter${var.recaptcha_site_key_parameter_name}"
        ]
      }
    ]
  })
}

# CloudWatch Logs permissions for ECS tasks  
resource "aws_iam_role_policy" "cloudwatch_logs_access" {
  name = "cloudwatch-logs-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:*:log-group:/ecs/${var.app_name}-*",
          "arn:aws:logs:${var.aws_region}:*:log-group:/ecs/${var.app_name}-*:*"
        ]
      }
    ]
  })
}

# SQS permissions for scraping service
resource "aws_iam_role_policy" "sqs_access" {
  name = "sqs-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.scraping_jobs.arn
      }
    ]
  })
}

# ==================== ECS Task Execution Role Policies ===================