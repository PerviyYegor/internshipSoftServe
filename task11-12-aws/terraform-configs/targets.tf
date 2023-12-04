data "aws_ami" "latest_amazon_linux_centos7" {
  owners      = ["125523088429"] # Owner ID for CentOS AMIs
  most_recent = true

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


resource "aws_instance" "targets" {
  count                       = length(var.target_instance_tags)
  ami                         = data.aws_ami.latest_amazon_linux_centos7.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_server_key.key_name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id, aws_security_group.allow_prometheusMetricsExporter.id]
  tags = {
    Name = var.target_instance_tags[count.index]
  }
}