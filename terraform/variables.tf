# ======================== Variables ======================== 

locals {
  environment = terraform.workspace
  domain = "in-crop.org"
  api_name = "${local.environment}-api.${local.domain}"
  api_url = "https://${local.api_name}"

  # If in production, environment_domain_name is just the root domain. If in staging/dev, environment_domain_name is subdomain.domain
  environment_domain_name = local.environment == var.production_env_name ? local.domain : "${local.environment}.${local.domain}"
  
  # Website URL appends https:// to the environment_domain_name
  website_url = "https://${local.environment_domain_name}"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "frontend_aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "isa-crop"
}

variable "production_env_name" {
  default = "prod"
}

# ======================== Variables ========================



# ======================== Generated DB Variables =========================

# --- Username ---
data "aws_secretsmanager_random_password" "db_username" {
  password_length = 10
  exclude_punctuation = true
  exclude_numbers = true
}

resource "aws_secretsmanager_secret" "db_username_secret" {
  name = "${var.app_name}-db-username-${local.environment}"
    recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_username_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_username_secret.id
  secret_string = data.aws_secretsmanager_random_password.db_username.random_password
  
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# --- Password ---
data "aws_secretsmanager_random_password" "db_password" {
  password_length = 50
  exclude_characters = "/\"@'\\/ " # Exclude characters that can cause issues in connection strings or require escaping
}

resource "aws_secretsmanager_secret" "db_password_secret" {
  name = "${var.app_name}-db-password-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = data.aws_secretsmanager_random_password.db_password.random_password
  
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ======================== Generated DB Variables =========================



# ======================== Generated Token Secrets =========================

# --- Farmer Access Token Secret ---
data "aws_secretsmanager_random_password" "farmer_access_token" {
  password_length = 50
}

resource "aws_secretsmanager_secret" "farmer_access_token_secret" {
  name = "${var.app_name}-farmer-access-token-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "farmer_access_token_secret_version" {
  secret_id     = aws_secretsmanager_secret.farmer_access_token_secret.id
  secret_string = data.aws_secretsmanager_random_password.farmer_access_token.random_password
}

# --- Farmer Refresh Token Secret ---
data "aws_secretsmanager_random_password" "farmer_refresh_token" {
  password_length = 50
}

resource "aws_secretsmanager_secret" "farmer_refresh_token_secret" {
  name = "${var.app_name}-farmer-refresh-token-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "farmer_refresh_token_secret_version" {
  secret_id     = aws_secretsmanager_secret.farmer_refresh_token_secret.id
  secret_string = data.aws_secretsmanager_random_password.farmer_refresh_token.random_password
}

# --- Password Reset Token Secret ---
data "aws_secretsmanager_random_password" "password_reset_token" {
  password_length = 50
}

resource "aws_secretsmanager_secret" "password_reset_token_secret" {
  name = "${var.app_name}-password-reset-token-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "password_reset_token_secret_version" {
  secret_id     = aws_secretsmanager_secret.password_reset_token_secret.id
  secret_string = data.aws_secretsmanager_random_password.password_reset_token.random_password
}

# --- Admin Access Token Secret ---
data "aws_secretsmanager_random_password" "admin_access_token" {
  password_length = 50
}

resource "aws_secretsmanager_secret" "admin_access_token_secret" {
  name = "${var.app_name}-admin-access-token-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin_access_token_secret_version" {
  secret_id     = aws_secretsmanager_secret.admin_access_token_secret.id
  secret_string = data.aws_secretsmanager_random_password.admin_access_token.random_password
}

# --- Admin Refresh Token Secret ---
data "aws_secretsmanager_random_password" "admin_refresh_token" {
  password_length = 50
}

resource "aws_secretsmanager_secret" "admin_refresh_token_secret" {
  name = "${var.app_name}-admin-refresh-token-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin_refresh_token_secret_version" {
  secret_id     = aws_secretsmanager_secret.admin_refresh_token_secret.id
  secret_string = data.aws_secretsmanager_random_password.admin_refresh_token.random_password
}

# ======================== Generated Token Secrets =========================



# ====================== Parameter Variable Names =========================

variable "openai_api_key_parameter_name" {
  description = "Parameter Store name for OpenAI API key"
  type        = string
  default     = "/isa-farm-conservation/OPENAI_API_KEY"
}

variable "recaptcha_secret_parameter_name" {
  description = "Parameter Store name for reCAPTCHA secret key"
  type        = string
  default     = "/isa-farm-conservation/RECAPTCHA_SECRET_KEY"
}

variable "sendgrid_api_key_parameter_name" {
  description = "Parameter Store name for SendGrid API key"
  type        = string
  default     = "/isa-farm-conservation/SENDGRID_API_KEY"
}

variable "recaptcha_site_key_parameter_name" {
  description = "Parameter Store name for reCAPTCHA site key"
  type        = string
  default     = "/isa-farm-conservation/VITE_RECAPTCHA_SITE_KEY"
}

variable "sendgrid_from_email_parameter_name" {
  description = "Parameter Store name for SendGrid from email address"
  type        = string
  default     = "/isa-farm-conservation/SENDGRID_FROM_EMAIL"
}

variable "ga4_measurement_id_parameter_name" {
  description = "Parameter Store name for GA4 measurement ID"
  type        = string
  default     = "/isa-farm-conservation/VITE_GA4_MEASUREMENT_ID"
}

# ====================== Parameter Variable Names =========================



# ======================== Admin Credentials =========================

# --- Admin Username ---
data "aws_secretsmanager_random_password" "admin_username" {
  password_length     = 12
  exclude_punctuation = true
  exclude_numbers     = true
}

resource "aws_secretsmanager_secret" "admin_username_secret" {
  name                    = "${var.app_name}-admin-username-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin_username_secret_version" {
  secret_id     = aws_secretsmanager_secret.admin_username_secret.id
  secret_string = data.aws_secretsmanager_random_password.admin_username.random_password

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# --- Admin Password ---
data "aws_secretsmanager_random_password" "admin_password" {
  password_length    = 24
  exclude_characters = "/\"@'\\ "
}

resource "aws_secretsmanager_secret" "admin_password_secret" {
  name                    = "${var.app_name}-admin-password-${local.environment}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.admin_password_secret.id
  secret_string = data.aws_secretsmanager_random_password.admin_password.random_password

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ======================== Admin Credentials =========================