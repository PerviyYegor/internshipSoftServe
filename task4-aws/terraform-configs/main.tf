provider "aws" {
  region = var.aws_region
}
data "aws_region" "current" {}

data "aws_ami" "latest_amazon_linux" {
  owners = ["125523088429"]  # Owner ID для CentOS AMIs
  most_recent= true

  filter {
    name   = "name"
    values = ["CentOS Linux 7*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "ec_instance" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_server_key.key_name
  subnet_id                   = aws_default_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_traffic.id]
  tags = {
    Name = var.instance_tag
  }
}


