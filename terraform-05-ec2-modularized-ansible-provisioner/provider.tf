terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "hangrybear-tf-backend-state-bucket"
    key = "ec2-ansible-handover/state.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
}