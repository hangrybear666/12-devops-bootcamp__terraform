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

  # default explicitly stated
  enable_nat_gateway = true
  # all private subnets will route through this shared NAT gateway
  single_nat_gateway = true
  # DNS names for instances such as EC2
  enable_dns_hostnames = true

  tags = {
    # mandatory tag for k8s cloud controller manager
    "kubernetes.io/cluster/tf-dev-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    # mandatory tag for k8s cloud controller manager
    "kubernetes.io/cluster/tf-dev-eks-cluster" = "shared"
    # so k8s service of type LoadBalancer distributes its Cloud Native Elastic Load Balancer in the public subnet
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    # mandatory tag for k8s cloud controller manager
    "kubernetes.io/cluster/tf-dev-eks-cluster" = "shared"
    # Load Balancer closed off to the internet
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"

  cluster_name = "tf-dev-eks-cluster"
  cluster_version = "1.30"
  # for accessing the cluster via kubectl from remote
  cluster_endpoint_public_access  = true

  subnet_ids = module.tf-dev-vpc.private_subnets
  vpc_id = module.tf-dev-vpc.vpc_id

  tags = {
    environment = "dev"
    application = "tf-dev"
  }

  eks_managed_node_groups = {
    # first node group
    tf-dev = {
      use_latest_ami_release_version = true
      ami_type = "AL2023_x86_64_STANDARD"
      name = "tf-dev-nodegroup"
      min_size     = 1
      max_size     = 3
      desired_size = 2
      capacity_type = "ON_DEMAND"
      instance_types = ["t2.small"]
      # to overwrite custom disk size and configure remote_access set flag to false
      # use_custom_launch_template = false
      # disk_size = 30
      //  remote_access = {
      //    ec2_ssh_key               = module.key_pair.key_pair_name
      //    source_security_group_ids = [aws_security_group.remote_access.id]
      //  }
    }
    # additional node group...
  }
}