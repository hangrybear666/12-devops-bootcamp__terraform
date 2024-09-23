provider "aws" {
  region = var.region
}

data "aws_availability_zones" "azs" {}

module "tf-dev-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "tf-dev-vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.azs.names

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/tf-dev-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/tf-dev-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/tf-dev-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"

  cluster_name = "tf-dev-eks-cluster"
  cluster_version = "1.27"
  cluster_endpoint_public_access  = true

  subnet_ids = module.tf-dev-vpc.private_subnets
  vpc_id = module.tf-dev-vpc.vpc_id

  tags = {
    environment = "development"
    application = "tf-dev"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }
}