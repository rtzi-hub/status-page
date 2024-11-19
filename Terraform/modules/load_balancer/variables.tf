variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs for the Load Balancer"
  type        = list(string)
}

