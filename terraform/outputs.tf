output "instance_id" {
  description = "ID of the NationalVote EC2 instance"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "application_url" {
  description = "Initial application URL"
  value       = "http://${aws_instance.app.public_ip}:5000"
}

output "security_group_id" {
  description = "Security group attached to the instance"
  value       = aws_security_group.app.id
}
