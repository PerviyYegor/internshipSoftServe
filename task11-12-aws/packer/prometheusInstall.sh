#!/bin/bash

sudo yum -y install wget epel-release
sudo yum install -y nano

sudo sed -i 's/SELINUX=permissive/SELINUX=disable/' /etc/selinux/config
sudo setenforce 0

sudo wget -O /tmp/prometheus.tar.gz  https://github.com/prometheus/prometheus/releases/download/v2.45.1/prometheus-2.45.1.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

tar -xvzf /tmp/prometheus.tar.gz 
sudo cp prometheus*/prometheus /usr/local/bin/
sudo cp prometheus*/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo cp -r prometheus*/consoles /etc/prometheus
sudo cp -r prometheus*/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

#sudo mv files/prometheus.yml /etc/prometheus/prometheus.yml
#sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

#sudo mv files/prometheus.service /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
#sudo systemctl start prometheus
sudo systemctl enable prometheus