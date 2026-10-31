# This will contain important info after terraform apply runs - Easy access to infrastructure values


# ======================== ApplicationLoad Balancer ========================

output "alb_dns_name" {
  description = "Load balancer DNS"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "ALB Route53 zone ID (for DNS records)"
  value       = aws_lb.main.zone_id
}

# Output the API domain URL (the ALB)
output "api_url" {
  description = "URL to access the API"
  value       = local.api_url
}

# ======================== Application Load Balancer ========================



# ======================== ECR Repository ========================

output "ecr_repository_url" {
  description = "Push Docker images here"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app.name
}

# ======================== ECR Repository ========================



# ======================== ECS Cluster ========================

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.backend.name
}

output "ecs_scraper_service_name" {
  description = "ECS scraper service name"
  value       = aws_ecs_service.scraper.name
}

output "ecs_ssurgo_service_name" {
  description = "ECS SSURGO service name"
  value       = aws_ecs_service.ssurgo.name
}

output "ecs_task_definition_family" {
  value     = aws_ecs_task_definition.backend.family
  sensitive = true
}

output "private_subnet_1_id" {
  value     = aws_subnet.private_1.id
  sensitive = true
}

output "private_subnet_2_id" {
  value     = aws_subnet.private_2.id
  sensitive = true
}

# Security Group IDs for different services
output "node_server_sg_id" {
  value     = aws_security_group.node_server.id
  sensitive = true
}

output "scraping_service_sg_id" {
  value     = aws_security_group.scraping_service.id
  sensitive = true
}

output "ssurgo_service_sg_id" {
  value     = aws_security_group.ssurgo_service.id
  sensitive = true
}

output "efs_sg_id" {
  value     = aws_security_group.efs.id
  sensitive = true
}

# This is sensitive, causing an error when output
# output "ecs_task_definition_family" {
#   description = "ECS task definition family"
#   value       = aws_ecs_task_definition.backend.family
# }

# ======================== ECS Cluster ========================



# ======================== Frontend ========================

output "frontend_bucket_name" {
  description = "S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend_s3.bucket
}

output "frontend_cloudfront_id" {
  description = "CloudFront distribution ID for frontend"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

# ======================== Frontend ========================



# ======================== RDS ========================

output "rds_instance_address" {
  value       = aws_db_instance.postgres.address
  description = "The DNS address (hostname) of the RDS instance"
  sensitive   = true
}

output "rds_instance_port" {
  value       = aws_db_instance.postgres.port
  description = "The database port"
  sensitive   = true
}

output "rds_instance_name" {
  value       = aws_db_instance.postgres.db_name
  description = "The database name"
  sensitive   = true
}

output "rds_instance_username" {
  value       = aws_db_instance.postgres.username
  description = "The master username for the database"
  sensitive = true
}

output "rds_instance_password" {
  value = aws_db_instance.postgres.password
  description = "The database password"
  sensitive = true
}

# ======================== RDS ========================



# ======================= SSM Parameters ========================

output "recaptcha_site_key" {
  description = "reCAPTCHA site key for frontend"
  value       = data.aws_ssm_parameter.recaptcha_site_key.insecure_value
}

output "ga4_measurement_id" {
  description = "GA4 Measurement ID for frontend analytics"
  value       = data.aws_ssm_parameter.ga4_measurement_id.insecure_value
}

# ======================= SSM Parameters ========================



# ======================= SQS ========================

output "scraping_jobs_queue_url" {
  description = "SQS queue URL for scraping jobs (set as SCRAPING_QUEUE_URL in production)"
  value       = aws_sqs_queue.scraping_jobs.url
}

# ======================= SQS ========================



# ======================= EFS File Systems ========================

output "efs_upload_files_id" {
  description = "EFS file system ID for upload files volume"
  value       = aws_efs_file_system.upload_files.id
}

output "efs_upload_files_access_point_id" {
  description = "EFS access point ID for upload files"
  value       = aws_efs_access_point.upload_files.id
}

# ======================= EFS File Systems ========================
