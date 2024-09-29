variable vpc_cidr_block {
  description = "CIDR block for the VPC"
  type        = string
  default = "10.0.0.0/16"
}
variable region {
  description = "AWS region for EC2 instance"
  type        = string
  default = "eu-central-1"
}
variable subnet_cidr_block {
  description = "CIDR block for Public Subnet /w Internet Access"
  type = string
  default = "10.0.10.0/24"
}
variable avail_zone {
  description = "AWS availability zone where the resources will be launched"
  type        = string
  default = "eu-central-1a"
}
variable env_prefix {
  description = "Application Prefix for e.g. tagging resources"
  type        = string
  default = "dev"
}
variable my_ip {
  description = "Your public IP for SSH access"
  type        = string
  default     = "0.0.0.0/0" # Update to your IP (e.g. "203.0.113.0/32") for security
}
variable jenkins_ip {
  description = "IP address of your jenkins server"
  type        = string
  default = "" # Update to your IP (e.g. "203.0.113.0/32") for security
}
variable instance_type {
  description = "The EC2 instance type to use"
  type        = string
  default = "t2.micro"
}
variable ssh_key_name {
  description = "name of existing keypair in aws console"
  type        = string
  default     = "your-key-name" # Update to your key
}