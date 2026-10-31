# ===================== SQS Queue for Scraping Jobs =====================
# Serial job queue for the web scraping service.
# ElasticMQ is used locally (docker-compose); this queue is used in production.

resource "aws_sqs_queue" "scraping_jobs" {
  name = "${var.app_name}-${local.environment}-scraping-jobs"

  # Match ElasticMQ local dev settings
  visibility_timeout_seconds = 3600
  receive_wait_time_seconds  = 20

  # Retain messages for 1 day in case of container restart
  message_retention_seconds = 86400

  tags = {
    Name        = "${var.app_name}-${local.environment}-scraping-jobs"
    Environment = local.environment
  }
}

# ===================== SQS Queue for Scraping Jobs =====================
