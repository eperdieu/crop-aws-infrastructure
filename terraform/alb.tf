# =================== Data Source for Cert and DNS ===================

# Use existing ACM certificate (same as frontend)
data "aws_acm_certificate" "main" {
  domain   = "*.${local.domain}"
  statuses = ["ISSUED"]
}

# Get the Route 53 hosted zone for the domain
data "aws_route53_zone" "main" {
  name         = local.domain
  private_zone = false
}

# =================== Data Source for Cert and DNS ===================



# =================== Application Load Balancer ===================

resource "aws_lb" "main" {
  name               = "${var.app_name}-alb-${local.environment}"  
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false
  
  # Increase idle timeout for long-running requests like web scraping
  idle_timeout = 3600  # 1 hour to match the 60-min abort signal in scrapeOnly()

  # Commented out to keep costs down - uncomment if we need ALB access logs
  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id  # S3 bucket for logs
  #   prefix  = "${var.app_name}-alb"
  #   enabled = true
  # }

  tags = {
    Name        = "${var.app_name}-alb-${local.environment}"
    Environment = local.environment
  }
}

#Defining Target group for ALB - Tells the ALB where to send the traffic
resource "aws_lb_target_group" "app" {
  name        = "${var.app_name}-tg-${local.environment}"
  port        = 5001      # Port the backend listens on
  protocol    = "HTTP"     # HTTP for SSL termination at ALB
  vpc_id      = aws_vpc.main.id
  target_type = "ip" 

  #This delay is set to wait for the removal of unhealthy targets (Verified by ALB)
  deregistration_delay = 30  

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"   # HTTP health check for backend
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.app_name}-tg-${local.environment}"
    Environment = local.environment
  }
}

#Listener for ALB - HTTPS with SSL certificate
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"      # Standard HTTPS port
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.main.arn

  # Default action - forward all HTTPS traffic to target group
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.app.arn
      }
    }
  }

  # Ensure listener is deleted before target group
  depends_on = [aws_lb_target_group.app]
}

#HTTP Listener - Redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"      # Standard HTTP port
  protocol          = "HTTP"

  # Redirect all HTTP traffic to HTTPS
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # Ensure listener is deleted before load balancer
  depends_on = [aws_lb.main]
}

# =================== Application Load Balancer =================== 



# =================== DNS Record =================== 

# Create DNS record pointing to the ALB
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.api_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_lb.main]
}

# =================== DNS Record =================== 
