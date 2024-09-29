output "ec2-public_ip" {
  value = aws_instance.tf-dev-server.public_ip
}
output "ec2-ssh-command" {
  value = "ssh -i <private_key_location> ec2-user@${aws_instance.tf-dev-server.public_ip}"
}