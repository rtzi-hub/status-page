# AWS region where resources will be deployed
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC CIDR block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

# Public subnet CIDR block
variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.1.1.0/24"
}

# Private subnet CIDR block
variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.1.2.0/24"
}

# Availability zone to deploy resources
variable "availability_zone" {
  description = "The AWS availability zone to deploy resources"
  type        = string
  default     = "us-east-1a"
}

# Instance type for Jenkins EC2
variable "instance_type" {
  description = "The instance type for the Jenkins EC2 instance"
  type        = string
  default     = "t3.medium"
}

# Name of the SSH key pair to access EC2 instance
variable "key_name" {
  description = "The name of the SSH key pair to use for the Jenkins EC2 instance"
  type        = string
  default     = "keypem-Ron1"
}

# Jenkins Security Group Name
variable "security_group_name" {
  description = "The security group name for the Jenkins EC2 instance"
  type        = string
  default     = "JenkinsSG"
}

# Tag for the Jenkins VPC
variable "vpc_name" {
  description = "The tag for the Jenkins VPC"
  type        = string
  default     = "y-r-JenkinsVPC"
}

# Tag for Jenkins EC2
variable "ec2_name" {
  description = "The tag name for Jenkins EC2 instance"
  type        = string
  default     = "y-r-JenkinsServer"
}
