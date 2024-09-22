
resource "linode_instance" "terraform-jenkins" {
  image = data.linode_images.debian-12-image.images.0.id
  label = "terraform-jenkins-vps"
  region = var.region
  swap_size = 1024
  type = var.instance_type
  authorized_keys = [var.public_key_content]
  tags = ["terraform-jenkins"]
  root_pass = var.root_password
}

data "linode_images" "debian-12-image" {
  latest = true
  filter {
    name = "label"
    values = ["Debian 12"]
  }

  filter {
    name = "is_public"
    values = ["true"]
  }
}

resource "linode_firewall" "jenkins-firewall" {
  label = "my_firewall"
  linodes = [linode_instance.terraform-jenkins.id]

  inbound {
    label    = "allow-SSH"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.my_ips
  }

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80,8080"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  # inbound {
  #   label    = "allow-https"
  #   action   = "ACCEPT"
  #   protocol = "TCP"
  #   ports    = "443,8443"
  #   ipv4     = ["0.0.0.0/0"]
  #   ipv6     = ["::/0"]
  # }

  inbound_policy = "ACCEPT"

  outbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound_policy = "ACCEPT"
}
