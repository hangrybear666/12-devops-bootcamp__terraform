output "debian_12_ami_id" {
  # value = module.tf-test-aws_instance.debian_12_ami
  value = module.tf-test-aws_instance.debian_12_ami.id
}
output "ec2-public_ip" {
  value = module.tf-test-aws_instance.ec2-instance.public_ip
}
output "ec2-ssh-command" {
  value = "ssh -i ${var.private_key_location} admin@${module.tf-test-aws_instance.ec2-instance.public_ip}"
}
