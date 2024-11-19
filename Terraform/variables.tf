variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

# VPC Configuration
variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "The CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "The CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# EKS Cluster Configuration
variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "y-r-cluster"
}

variable "node_group_name" {
  description = "The name of the EKS node group."
  type        = string
  default     = "y-r-eks-node-group"
}

variable "node_instance_type" {
  description = "The instance type for the EKS nodes."
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "The number of desired EKS nodes."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum number of EKS nodes."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "The minimum number of EKS nodes."
  type        = number
  default     = 1
}

# RDS Database Configuration
variable "db_instance_class" {
  description = "The instance class for the RDS database."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The amount of storage (in GB) to allocate for the RDS instance."
  type        = number
  default     = 20  # You can set a default value if needed
}


variable "db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "statuspage"
}

variable "db_username" {
  description = "The username for the RDS database."
  type        = string
  default     = "statuspage"
}

variable "db_password" {
  description = "The password for the RDS database."
  type        = string
  default     = "mypassword"
}

variable "db_backup_retention" {
  description = "The backup retention period (in days) for the RDS database."
  type        = number
  default     = 7
}

# Load Balancer Configuration
variable "lb_name" {
  description = "The name of the load balancer."
  type        = string
  default     = "my-load-balancer"
}

variable "lb_port" {
  description = "The port for the load balancer."
  type        = number
  default     = 80
}

variable "lb_protocol" {
  description = "The protocol for the load balancer."
  type        = string
  default     = "HTTP"
}


