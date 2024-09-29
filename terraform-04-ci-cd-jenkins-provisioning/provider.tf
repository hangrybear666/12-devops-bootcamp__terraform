terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "tf-dev-bucket-ec2"
    key = "tf-dev/state.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}
