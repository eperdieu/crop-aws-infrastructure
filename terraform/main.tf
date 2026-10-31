terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "example_app"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "private_route_table_ids" {
  type = list(string)
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

# Container registry for the app images
resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECS cluster that runs the Fargate tasks
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}_cluster"
}

# Allow HTTPS from inside the VPC to the endpoints
resource "aws_security_group" "endpoints" {
  name        = "${var.app_name}_endpoints"
  description = "HTTPS from the VPC to interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }
}

# Interface endpoints let private Fargate tasks reach AWS services
# (pull images, read secrets, write logs) without a NAT Gateway.
locals {
  interface_services = ["ecr.api", "ecr.dkr", "secretsmanager", "logs"]
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = toset(local.interface_services)
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
}

# ECR stores image layers in S3, so a gateway endpoint is needed too
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
}
