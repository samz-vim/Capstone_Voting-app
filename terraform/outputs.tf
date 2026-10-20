
output "instance_id" {
  value = aws_instance.nationalvote.id
}

output "public_ip" {
  value = aws_instance.nationalvote.public_ip
}

output "ssh_command" {
  value = "ssh -i your-key.pem ubuntu@${aws_instance.nationalvote.public_ip}"
}

output "application_url" {
  value = "http://${aws_instance.nationalvote.public_ip}:30080"
}
