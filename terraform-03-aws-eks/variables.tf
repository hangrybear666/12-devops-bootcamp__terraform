
variable vpc_cidr_block {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable region {
  description = "AWS region for EKS cluster"
  type        = string
  default     =  "eu-central-1"
}

variable public_subnet_cidr_blocks {
  description = "CIDR blocks for Public Subnet /w Internet Access"
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}

variable private_subnet_cidr_blocks {
  description = "CIDR blocks Private Subnet /wo Internet Access"
  type = list(string)
  default = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
}