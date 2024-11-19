# VPC and Networking Variables
variable "vpc_id" {
  description = "VPC ID to create the EKS cluster in"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS node group"
  type        = list(string)
}


variable "security_group_ids" {
  description = "List of security group IDs for EKS"
  type        = list(string)
}

# EKS Cluster Variables
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "y-r-cluster"
}

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

# EKS Node Group Variables
variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "y-r-eks-node-group"
}

variable "eks_node_group_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  type        = string
}

variable "desired_capacity" {
  description = "The desired number of EKS nodes"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "The maximum number of EKS nodes"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "The minimum number of EKS nodes"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "The instance type for the EKS nodes"
  type        = string
  default     = "t2.medium"
}

variable "eks_worker_node_policy_attachment" {
  description = "IAM policy ARN for the EKS worker node group"
  type        = string
}

variable "eks_cni_policy_attachment" {
  description = "IAM policy ARN for the EKS CNI"
  type        = string
}

variable "ecr_read_only_policy_attachment" {
  description = "IAM policy ARN for read-only access to ECR"
  type        = string
}
