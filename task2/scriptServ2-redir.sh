#!/bin/bash

sudo yum install -y epel-release
sudo yum install -y nano traceroute

##
sudo yum install -y iptables-services

sudo iptables --table nat --append PREROUTING -p tcp --destination  192.168.2.10 --dport 80 --jump DNAT --to-destination 192.168.1.10:81
sudo iptables --table nat --append POSTROUTING -p tcp --destination 192.168.1.10 --dport 81 --jump SNAT --to-source 192.168.2.10
sudo sysctl -w net.ipv4.ip_forward=1


sudo sh -c "iptables-save > /etc/sysconfig/iptables"




