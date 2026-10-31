# =================== RDS Database ====================

# Groups subnets for RDS instances, ensuring they are placed in private subnets for security.
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.app_name}-db-subnet-group-${local.environment}"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name        = "${var.app_name}-db-subnet-group-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_db_instance" "postgres" {
    identifier              = "${var.app_name}-db-instance-${local.environment}"
    allocated_storage       = 10
    engine                  = "postgres"
    engine_version          = "17.6"   # TODO: need to define the version of Postgres we want to use
    instance_class          = "db.t4g.micro"
    db_name                 = "ISADB${local.environment}"
    username                = aws_secretsmanager_secret_version.db_username_secret_version.secret_string
    password                = aws_secretsmanager_secret_version.db_password_secret_version.secret_string
    db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
    vpc_security_group_ids  = [aws_security_group.rds.id]
    skip_final_snapshot     = false   # Setting this to false will create a snapshot of the database before deletion
    final_snapshot_identifier = "${var.app_name}-db-instance-${local.environment}-final-snapshot-${replace(timestamp(), ":", "-")}"

    lifecycle {
      ignore_changes = [password, username, final_snapshot_identifier]
    }

    tags = {
        Name        = "${var.app_name}-db-instance-${local.environment}"
        Environment = local.environment
    }
}

# =================== RDS Database ====================
