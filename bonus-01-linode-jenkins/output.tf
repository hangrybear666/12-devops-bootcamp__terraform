output "linode-public_ip" {
  value = linode_instance.terraform-jenkins.ip_address
}
output "linode-ssh-command" {
  value = "ssh -i ${var.private_key_location} root@${linode_instance.terraform-jenkins.ip_address}"
}
