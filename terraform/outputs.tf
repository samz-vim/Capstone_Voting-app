
output "instance_id" {
  value = aws_instance.nationalvote.id
}

output "instance_public_ip" {
  description = "Public IP address of the NationalVote EC2 instance"
  value       = aws_instance.nationalvote.public_ip
}

output "ssh_command" {
  value = "ssh -i your-key.pem ubuntu@${aws_instance.nationalvote.public_ip}"
}

output "application_url" {
  value = "http://${aws_instance.nationalvote.public_ip}:30080"
}
