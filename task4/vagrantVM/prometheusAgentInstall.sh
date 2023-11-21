#!/bin/bash

sudo yum update -y
sudo yum -y install wget epel-release
sudo yum install -y nano

sudo sed -i 's/SELINUX=permissive/SELINUX=disable/' /etc/selinux/config
sudo setenforce 0

sudo wget -O /tmp/prometheusAgent.tar.gz  https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvzf /tmp/prometheusAgent.tar.gz 

sudo mv node_exporter-*/node_exporter /usr/local/bin/node_exporter

sudo useradd -rs /bin/false nodeusr

sudo mv /home/vagrant/node_exporter.service /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload

sudo systemctl enable node_exporter
sudo systemctl start node_exporter

sudo mv /home/vagrant/daemon.json /etc/docker/daemon.json

sudo systemctl restart docker
docker start apache