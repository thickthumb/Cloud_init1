terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "4.43.0"
    }
  }
}

provider "aws" {
  region = var.default_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "vpc_thumb1" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "name" = "main_vpc "
  }
}

resource "aws_subnet" "net_thumb1" {
  cidr_block = var.subnet
  vpc_id = aws_vpc.vpc_thumb1.id
  availability_zone = "us-west-1a"
  tags = {
    "name" = "aws_subnet"

  }
}

resource "aws_internet_gateway" "igw_thumb1" {
  vpc_id = aws_vpc.vpc_thumb1.id
  tags = {
    "name" = "name"
    value = "First gateway"
  }
}
resource "aws_default_route_table" "thumb1_table" {
  default_route_table_id = aws_vpc.vpc_thumb1.default_route_table_id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_thumb1.id
  }
  tags = {
    "name" = "default_route_table"
  }
}
resource "aws_default_security_group" "thumb1_security_grp" {
  vpc_id = aws_vpc.vpc_thumb1.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "name" = "def sec grp"
  }
  
}

resource "aws_key_pair" "ec2_keypair" {
  public_key = file(var.ssh_public_key)
  key_name = "instance_keypair"

}

data "aws_ami" "new_amazon_linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "user_data" {
  template = file("./web-app-template.yaml")
}

resource "aws_instance" "ec2_instance"  {
  ami = data.aws_ami.new_amazon_linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.net_thumb1.id
  vpc_security_group_ids = [aws_default_security_group.thumb1_security_grp.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.ec2_keypair.key_name
  user_data = data.template_file.user_data.rendered

  tags = {
    "name" = "name"
    value = "test_linux_inst"
  }
}




# resource "aws_instance" "ec2_instance2"  {
#   ami = data.aws_ami.new_amazon_linux.id
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.net_thumb1.id
#   vpc_security_group_ids = [aws_default_security_group.thumb1_security_grp.id]
#   associate_public_ip_address = true
#   key_name = aws_key_pair.ec2_keypair.key_name
#   user_data = file("open_script.sh")

#   tags = {
#     "name" = "name"
#     value = "jenkins_inst"
#   }
# }


