# =================== CloudWatch Logs =================== 

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}-${local.environment}"
  retention_in_days = 7

  tags = {
    Name        = "${var.app_name}-logs-${local.environment}"
    Environment = local.environment
  }
}

# =================== CloudWatch Logs =================== 
