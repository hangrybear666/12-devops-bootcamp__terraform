
variable "my_ips" {
  description = "Your public IP for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Update to your IP (e.g. "203.0.113.0/32") for security
}

variable "public_key_content" {
  description = "Your actual public key received via $(cat PUB_KEY_PATH)"
  type        = string
}

variable "private_key_location" {
  description = "Path to your private SSH key"
  type        = string
  default     = "~/.ssh/id_rsa"  # Update to the correct key path if necessary
}

variable "instance_type" {
  description = "Linode Instance Type"
  type        = string
  default     =  "g6-standard-2"
}

variable "region" {
  description = "Linode Region"
  type        = string
  default     =  "eu-central"
}

variable "root_password" {
  description = "Root password for the Linode instance saved in .env file via setup-linode.sh"
  type        = string
  sensitive   = true # Prevents it from being shown in logs
}

variable "http_inbound_ports" {
  description = "Ports open for HTTP ingress access from outside"
  type = string
  default = "80, 8080"
}

variable "instance_count" {
  description = "The Linode instances you desire"
  type        = number
  default     = 1
}