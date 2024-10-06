terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.28.0"
    }
  }
  backend "s3" {
    bucket = "hangrybear-tf-backend-state-bucket"
    key = "linode-generic/state.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
}

provider "linode" {
  # Configuration options
}