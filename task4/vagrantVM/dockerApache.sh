#!/bin/bash
sudo systemctl enable docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum  install -y terraform
terraform init
terraform apply -auto-approve