output "debian_12_ami_id" {
  # value = data.aws_ami.debian-12-image
  value = data.aws_ami.debian-12-image.id
}
output "ec2-public_ip" {
  value = aws_instance.tf-test-server.public_ip
}
output "ec2-ssh-command" {
  value = "ssh -i ${var.private_key_location} admin@${aws_instance.tf-test-server.public_ip}"
}
