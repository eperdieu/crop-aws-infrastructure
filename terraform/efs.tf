# ===================== EFS File Systems for Shared Volumes =====================

# Upload Files shared volume — shared between node server and ssurgo containers
# (equivalent to docker-compose upload-files volume; use EFS in production)
resource "aws_efs_file_system" "upload_files" {
  creation_token = "${var.app_name}-${local.environment}-upload-files"
  
  performance_mode = "generalPurpose" 
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = 10  # Minimal throughput for cost efficiency

  # Enable encryption at rest
  encrypted = true

  tags = {
    Name        = "${var.app_name}-${local.environment}-upload-files"
    Environment = local.environment
    Purpose     = "Shared upload directory for file processing"
  }
}

# ===================== EFS Mount Targets =====================

# Upload Files mount targets in private subnets for Node server and SSURGO service
resource "aws_efs_mount_target" "upload_files_private_1" {
  file_system_id  = aws_efs_file_system.upload_files.id
  subnet_id       = aws_subnet.private_1.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "upload_files_private_2" {
  file_system_id  = aws_efs_file_system.upload_files.id
  subnet_id       = aws_subnet.private_2.id
  security_groups = [aws_security_group.efs.id]
}


# ===================== EFS Access Points =====================

# Upload Files access point
resource "aws_efs_access_point" "upload_files" {
  file_system_id = aws_efs_file_system.upload_files.id
  
  posix_user {
    uid = 1001
    gid = 1001
  }
  
  root_directory {
    path = "/uploads"
    creation_info {
      owner_uid   = 1001
      owner_gid   = 1001
      permissions = 755
    }
  }

  tags = {
    Name        = "${var.app_name}-${local.environment}-upload-files-ap"
    Environment = local.environment
  }
}
