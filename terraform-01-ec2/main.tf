provider "aws" {}

resource "aws_vpc" "tf-test-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "tf-test-subnet-1" {
  vpc_id = aws_vpc.tf-test-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "tf-test-igw" {
  vpc_id = aws_vpc.tf-test-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

/*
// Alternative to explicit aws_route_table in which case we can delete the aws_route_table_association since all unassigned subnets automatically get assigned to the default/main route table
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.tf-test-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-test-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}
*/
resource "aws_route_table" "tf-test-route-table" {
  vpc_id = aws_vpc.tf-test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-test-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-route-table"
  }
}

resource "aws_route_table_association" "rtb-subnet-association" {
  subnet_id = aws_subnet.tf-test-subnet-1.id
  route_table_id = aws_route_table.tf-test-route-table.id
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.tf-test-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = var.my_ips
  }

  # ingress {
  #   from_port = 8080
  #   to_port = 8080
  #   protocol = "TCP"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "debian-12-image" {
  most_recent = true
  owners      = ["136693071363"]  # Debian's official AWS account ID

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "tf-server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "tf-test-server" {
  ami = data.aws_ami.debian-12-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.tf-test-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("payload/install-git-on-debian-ec2.sh")

  user_data_replace_on_change = true

  tags = {
    Name: "${var.env_prefix}-server"
  }
}
