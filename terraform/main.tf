provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "bitbucket-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "bitbucket-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "bitbucket-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "bitbucket-private-subnet"
  }
}

# Additional Private Subnet for RDS
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "bitbucket-private-subnet-2"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "bitbucket-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "bitbucket" {
  name        = "bitbucket-sg"
  description = "Security group for Bitbucket server"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Bitbucket HTTP
  ingress {
    from_port   = 7990
    to_port     = 7990
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Bitbucket SSH
  ingress {
    from_port   = 7999
    to_port     = 7999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Elasticsearch HTTP
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Elasticsearch nodes communication
  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bitbucket-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "bitbucket-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  # PostgreSQL access from Bitbucket instance
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bitbucket.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bitbucket-rds-sg"
  }
}

# EFS Security Group
resource "aws_security_group" "efs" {
  name        = "bitbucket-efs-sg"
  description = "Security group for EFS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.bitbucket.id]
  }
}

# EC2 Instance
resource "aws_instance" "bitbucket" {
  ami           = "ami-0440d3b780d96b29d"  # Amazon Linux 2023 AMI in us-east-1
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bitbucket.id]

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "bitbucket-server"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name        = "bitbucket-db-subnet-group"
  description = "Subnet group for Bitbucket RDS"
  subnet_ids  = [aws_subnet.private.id, aws_subnet.private_2.id]

  tags = {
    Name = "bitbucket-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "bitbucket" {
  identifier           = "bitbucket-db"
  engine              = "postgres"
  engine_version      = "13"
  instance_class      = "db.t3.medium"
  allocated_storage   = 20
  storage_type        = "gp2"
  db_name             = "bitbucket"
  username            = "bitbucket"
  password            = var.db_password
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

# EFS File System
resource "aws_efs_file_system" "bitbucket" {
  creation_token = "bitbucket-efs"
  encrypted      = true

  tags = {
    Name = "bitbucket-efs"
  }
}

resource "aws_efs_mount_target" "bitbucket" {
  file_system_id  = aws_efs_file_system.bitbucket.id
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.efs.id]
}
