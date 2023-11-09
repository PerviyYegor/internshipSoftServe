#!/bin/bash

sudo mv /home/vagrant/index.html /usr/share/nginx/html/index.html
sudo mv /home/vagrant/nginx.conf /etc/nginx/nginx.conf
sudo systemctl start nginx

