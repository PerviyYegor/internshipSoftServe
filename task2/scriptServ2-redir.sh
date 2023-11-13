#!/bin/bash

sudo yum install -y epel-release
sudo yum install -y nano traceroute
#sudo setenforce 0
#sudo mv /home/vagrant/nginx.conf /etc/nginx/nginx.conf
#sudo systemctl start nginx

##
sudo yum install -y iptables-services

sudo iptables --table nat --append PREROUTING -p tcp --destination  192.168.2.10 --dport 80 --jump DNAT --to-destination 192.168.1.10:81
sudo iptables --table nat --append POSTROUTING -p tcp --destination 192.168.1.10 --dport 81 --jump SNAT --to-source 192.168.2.10
sudo sysctl -w net.ipv4.ip_forward=1

#sudo iptables -t nat -A OUTPUT -p tcp  --dport 80 -j DNAT --to-destination 192.168.1.10:81
##
#sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
#sudo iptables -t nat -A OUTPUT -p tcp -o eth1 --dport 80 -j DNAT --to-destination 192.168.1.10:81

sudo sh -c "iptables-save > /etc/sysconfig/iptables"




