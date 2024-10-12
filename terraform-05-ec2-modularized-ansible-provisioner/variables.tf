variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet within the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "avail_zone" {
  description = "AWS availability zone where the resources will be launched"
  type        = string
  default     = "eu-central-1b"
}

variable "env_prefix" {
  description = "Application Prefix for e.g. tagging resources"
  type        = string
  default     = "dev"
}

variable "my_ips" {
  description = "Your public IP for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Update to your IP (e.g. "203.0.113.0/32") for security
}

variable "instance_type" {
  description = "The EC2 instance type to use"
  type        = string
  default     = "t2.micro"
}
variable "instance_count" {
  description = "The EC2 instances you desire"
  type        = number
  default     = 3
}
variable "public_key_location" {
  description = "Path to your public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"  # Update to the correct key path if necessary
}

variable "private_key_location" {
  description = "Path to your private SSH key"
  type        = string
  default     = "~/.ssh/id_rsa"  # Update to the correct key path if necessary
}

variable "ansible_work_directory" {
  description = "Path to your ansible project for handover"
  type        = string
  default     = "/home/admin/git/15-devops-bootcamp__ansible/04-ec2-deploy-docker-compose-from-terraform"
}

variable "ansible_java_app_version" {
  description = "Java Image Application Target Version for ansible to build & deploy"
  type        = string
  default     = "1.0"
}