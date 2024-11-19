resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "y-r-rds-private-subnet-group"
  subnet_ids = var.private_subnet_ids   # Use only private subnets

  tags = {
    Name = "Y R RDS Private Subnet Group"
    Project = "TeamE"
  }
}

# RDS Security Group
resource "aws_security_group" "db_SG" {
  name_prefix = "db-SG-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]  # Use EKS node security group for access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "Y-R DB Security Group"
    Project = "TeamE"
  }
}

# RDS Instance
resource "aws_db_instance" "db_insta" {
  engine                 = "postgres"
  db_name                = var.db_name
  identifier             = "y-r"
  instance_class         = var.db_instance_class
  allocated_storage      = var.allocated_storage
  publicly_accessible    = false # Keep it private :)
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.db_SG.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot    = true
  multi_az               = true
  snapshot_identifier    = "arn:aws:rds:us-east-1:992382545251:snapshot:y-r-superuser"


  tags = {
    Name    = "Y-R-db"
    Project = "TeamE"
  }
  depends_on = [aws_db_subnet_group.db_subnet_group]
}
