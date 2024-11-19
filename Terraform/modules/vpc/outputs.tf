output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for subnet in values(aws_subnet.public) : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in values(aws_subnet.private) : subnet.id]
}

output "eks_node_sg_id" {
  description = "The security group ID for the EKS worker nodes."
  value       = aws_security_group.eks_node_sg.id
}

