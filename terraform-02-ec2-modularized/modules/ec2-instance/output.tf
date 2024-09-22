output "debian_12_ami" {
  value = data.aws_ami.debian-12-image
}
output "ec2-instance" {
  value = aws_instance.tf-test-server
}