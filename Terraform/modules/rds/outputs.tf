output "db_instance_endpoint" {
  value       = aws_db_instance.db_insta.endpoint
  description = "The endpoint of the RDS instance"
}
