#!/bin/bash

sudo yum -y install wget epel-release
sudo yum install -y nano


sudo sed -i 's/SELINUX=permissive/SELINUX=disable/' /etc/selinux/config
sudo setenforce 0


#install prometheus
sudo wget -O /tmp/prometheus.tar.gz  https://github.com/prometheus/prometheus/releases/download/v2.45.1/prometheus-2.45.1.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

tar -xvzf /tmp/prometheus.tar.gz 
sudo mv prometheus*/prometheus /usr/local/bin/
sudo mv prometheus*/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo mv prometheus*/consoles /etc/prometheus
sudo mv prometheus*/console_libraries /etc/prometheus
sudo mv prometheus*/prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

#install alertmanager
sudo wget -O /tmp/alertmanager.tar.gz https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mkdir /etc/alertmanager

cd /tmp
tar -xvf alertmanager.tar.gz
sudo mv alertmanager*/alertmanager /usr/local/bin/
sudo mv alertmanager*/amtool /usr/local/bin/

sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool
sudo mv alertmanager*/alertmanager.yml /etc/alertmanager/
sudo chown -R alertmanager:alertmanager /etc/alertmanager/


#enable services
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl enable alertmanager