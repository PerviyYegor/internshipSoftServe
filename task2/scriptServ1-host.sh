#!/bin/bash
sudo yum install -y epel-release
sudo yum install -y nginx nano traceroute

sudo setenforce 0

sudo mv /home/vagrant/index.html /usr/share/nginx/html/index.html
sudo mv /home/vagrant/nginx.conf /etc/nginx/nginx.conf
sudo systemctl start nginx

