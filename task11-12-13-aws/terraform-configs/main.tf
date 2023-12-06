provider "aws" {
  region = var.aws_region
}
data "aws_region" "current" {}

data "aws_ami" "latest_amazon_linux_centos7_prometheus" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ami-prometheusCentos*"]
  }
}

resource "aws_instance" "prometheus" {
  ami                         = data.aws_ami.latest_amazon_linux_centos7_prometheus.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_server_key.key_name
  subnet_id                   = aws_default_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_traffic.id]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name


  tags = {
    Name = var.instance_tag
  }
}

resource "null_resource" "execute-remote" {
  connection {
    type        = "ssh"
    user        = "centos"
    private_key = tls_private_key.terraform_key.private_key_pem
    host        = aws_instance.prometheus.public_ip
  }
  provisioner "file" {
    source      = "files/"
    destination = "/home/centos"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/centos/prometheus.yml /etc/prometheus/prometheus.yml",
      "sudo mv /home/centos/alert-rules.yml /etc/prometheus/alert-rules.yml",
      "sudo mv /home/centos/alertmanager.yml /etc/alertmanager/alertmanager.yml",
      "sudo systemctl restart prometheus",
      "sudo systemctl restart alertmanager"
    ]
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
