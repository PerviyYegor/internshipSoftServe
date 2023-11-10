#!/bin/bash
sudo yum install iptables-services

sudo sysctl -w net.ipv4.conf.eth0.route_localnet=1
sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10:81
sudo iptables-save



