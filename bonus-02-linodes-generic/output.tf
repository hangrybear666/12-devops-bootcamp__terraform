output "linode-public_ip" {
  value = [for instance in linode_instance.tf_linode_instances : instance.ip_address]
}
output "linode-ssh-command" {
  value = [for instance in linode_instance.tf_linode_instances : "ssh -i ${var.private_key_location} root@${instance.ip_address}"]
}
