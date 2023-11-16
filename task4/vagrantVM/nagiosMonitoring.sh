#!/bin/bash
sudo yum install -y nrpe python3 wget
sudo yum install -y nagios-plugins-{load,http,users,procs,disk,swap,nrpe,uptime} -y
wget -O /usr/local/bin/check_docker https://raw.githubusercontent.com/timdaman/check_docker/master/check_docker/check_docker.py
chmod +x /usr/local/bin/check_docker


sudo mv /home/vagrant/nrpe.cfg /etc/nagios/nrpe.cfg 
sudo systemctl enable nrpe
sudo systemctl restart nrpe