output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.jenkins_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "jenkins_ec2_public_ip" {
  description = "The public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_ec2.public_ip
}

output "jenkins_ec2_id" {
  description = "The ID of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_ec2.id
}
