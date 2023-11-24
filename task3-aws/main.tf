provider "aws" {
  region = "us-east-1"
}
data "aws_region" "current" {}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id = aws_vpc.main.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id = aws_vpc.main.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_security_group" "allow_prometheus" {
  name = "allow_prometheus"
  description = "Allow Prometheus traffic"
  vpc_id = aws_vpc.main.id
  ingress {
    description = "mysqlExporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "nodeExporter"
    from_port   = 9104
    to_port     = 9104
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}


resource "tls_private_key" "terraform_key" {
  algorithm   = "RSA" 
  rsa_bits = "2048" 
}

resource "local_file" "privet_key" {
    content     =tls_private_key.terraform_key.private_key_pem
    filename = "terraform.pem"
    file_permission = 0777
}


resource "aws_key_pair" "web_server_key" {
  key_name = "terraform"
  public_key = tls_private_key.terraform_key.public_key_openssh
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true

  tags = {
    Name = "AWS VPC"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id  
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = aws_vpc.main.cidr_block
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_route_table" "route_table" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gateway.id
 }
}

resource "aws_route_table_association" "route_table_association" {
 subnet_id      = aws_subnet.main.id
 route_table_id = aws_route_table.route_table.id
}

resource "aws_instance" "wordpress" {
  ami             = "ami-0aedf6b1cb669b4c7"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.web_server_key.key_name
  subnet_id = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id,aws_security_group.allow_prometheus.id]
}

resource "local_file" "ip" {
  content  = aws_instance.wordpress.public_ip
  filename = "ip.txt"
}


