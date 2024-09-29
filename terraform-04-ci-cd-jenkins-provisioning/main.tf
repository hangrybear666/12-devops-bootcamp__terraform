resource "aws_vpc" "tf-dev-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "tf-dev-subnet-1" {
  vpc_id = aws_vpc.tf-dev-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
    tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "tf-dev-igw" {
  vpc_id = aws_vpc.tf-dev-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.tf-dev-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-dev-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.tf-dev-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = concat([var.my_ip], [var.jenkins_ip])
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "tf-dev-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.tf-dev-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = var.ssh_key_name

  user_data = file("entry-script.sh")

  user_data_replace_on_change = true

  tags = {
    Name: "${var.env_prefix}-server"
  }
}