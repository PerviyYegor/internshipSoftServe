packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "ami_name" {
  type    = string
  default = "ami-prometheusCentos"
}

variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "base_ami" {
  type    = string
  default = "ami-0bcd12d19d926f8e9"
}

variable "instance_size" {
  type    = string
  default = "t2.micro"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_username" {
  type    = string
  default = "centos"
}

data "amazon-ami" "autogenerated_1" {
  filters = {
    architecture        = "x86_64"
    name                = "CentOS Linux 7*"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["125523088429"]
  region      = "${var.region}"
}

source "amazon-ebs" "autogenerated_1" {
  ami_name                    = "${var.ami_name}"
  associate_public_ip_address = true
  instance_type               = "${var.instance_size}"
  region                      = "${var.region}"
  source_ami                  = "${data.amazon-ami.autogenerated_1.id}"
  ssh_pty                     = "true"
  ssh_timeout                 = "20m"
  ssh_username                = "${var.ssh_username}"
  tags = {
    BuiltBy = "Packer"
    Name    = "Prometheus"
  }
}

build {
  description = "AWS image"

  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "file" {
    destination = "/home/centos/prometheus-alertmanager-install.sh"
    source      = "./prometheus-alertmanager-install.sh"
  }

  provisioner "file" {
    destination = "/tmp/prometheus.service"
    source      = "./files/prometheus.service"
  }
  provisioner "file" {
    destination = "/tmp/alertmanager.service"
    source      = "./files/alertmanager.service"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/prometheus.service /etc/systemd/system/prometheus.service",
    "sudo mv /tmp/alertmanager.service /etc/systemd/system/alertmanager.service", 
    "chmod +x /home/centos/prometheus-alertmanager-install.sh", 
    "/home/centos/prometheus-alertmanager-install.sh"]
  }

}