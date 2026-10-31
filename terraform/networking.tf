# =================== VPC + Networking  =================== 

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc-${local.environment}"
    Environment = local.environment
  }
}


# =================== Public Subnets ===================

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-1-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-2-${local.environment}"
    Environment = local.environment
  }
}


# =================== Private Subnets ===================

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.app_name}-private-subnet-1-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.app_name}-private-subnet-2-${local.environment}"
    Environment = local.environment
  }
}


# =================== Internet Gateway ===================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.app_name}-igw-${local.environment}"
    Environment = local.environment
  }
}


# =================== NAT Gateway ===================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.app_name}-nat-eip-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name        = "${var.app_name}-nat-gateway-${local.environment}"
    Environment = local.environment
  }

  depends_on = [aws_internet_gateway.main]
}


# =================== Public Route Table ===================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.app_name}-public-rt-${local.environment}" #Route table name
    Environment = local.environment
  }
}


# =================== Private Route Table ===================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.app_name}-private-rt-${local.environment}"
    Environment = local.environment
  }
}


# =================== Route Table Associations ===================

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# =================== VPC + Networking  =================== 



# =================== Security Groups =================== 

# ALB Security Group - Controls what can talk to the load balancer
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg-${local.environment}"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allows HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (safe because we control ALB targets)"
  }

  tags = {
    Name        = "${var.app_name}-alb-sg-${local.environment}"
    Environment = local.environment
  }
}

# Node Server Security Group (Private Subnet) - Only accessible from ALB
resource "aws_security_group" "node_server" {
  name        = "${var.app_name}-node-server-sg-${local.environment}"
  description = "Security group for Node server in private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow HTTP from ALB only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (for API calls, database, public services)"
  }

  tags = {
    Name        = "${var.app_name}-node-server-sg-${local.environment}"
    Environment = local.environment
  }
}

# Scraping Service Security Group (Public Subnet) - Only accessible from Node Server
resource "aws_security_group" "scraping_service" {
  name        = "${var.app_name}-scraping-service-sg-${local.environment}"
  description = "Security group for scraping service in public subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8001
    to_port         = 8001
    protocol        = "tcp"
    security_groups = [aws_security_group.node_server.id]
    description     = "Allow HTTP from Node server only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (for web scraping)"
  }

  tags = {
    Name        = "${var.app_name}-scraping-service-sg-${local.environment}"
    Environment = local.environment
  }
}

# SSURGO Service Security Group (Private Subnet) - Accessible from Node Server + Database Access
resource "aws_security_group" "ssurgo_service" {
  name        = "${var.app_name}-ssurgo-service-sg-${local.environment}"
  description = "Security group for SSURGO service in private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.node_server.id]
    description     = "Allow HTTP from Node server only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.app_name}-ssurgo-service-sg-${local.environment}"
    Environment = local.environment
  }
}

# RDS Security Group - Allow access from Node Server and SSURGO Service
resource "aws_security_group" "rds" {
  name        = "${var.app_name}-rds-sg-${local.environment}"
  description = "Security group for RDS - allows access from Node server and SSURGO service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.node_server.id]
    description     = "Allow PostgreSQL from Node server"
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ssurgo_service.id]
    description     = "Allow PostgreSQL from SSURGO service"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.app_name}-rds-sg-${local.environment}"
    Environment = local.environment
  }
}

# EFS Security Group - Allow access between Node Server (private) and SSURGO Service (private)
resource "aws_security_group" "efs" {
  name        = "${var.app_name}-efs-sg-${local.environment}"
  description = "Security group for EFS - allows NFS access from Node server and SSURGO service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.node_server.id]
    description     = "Allow NFS from Node server"
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ssurgo_service.id]
    description     = "Allow NFS from SSURGO service (both in private subnets)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.app_name}-efs-sg-${local.environment}"
    Environment = local.environment
  }
}

# =================== Security Groups =================== 
