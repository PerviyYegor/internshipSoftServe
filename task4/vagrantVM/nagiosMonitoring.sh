#!/bin/bash
sudo yum install -y nrpe python3 wget
sudo yum install -y nagios-plugins-{load,http,users,procs,disk,swap,nrpe,uptime} -y
sudo mv /home/vagrant/check_docker /usr/local/bin/check_docker
chmod +x /usr/local/bin/check_docker
sudo usermod -aG docker nrpe



sudo mv /home/vagrant/nrpe.cfg /etc/nagios/nrpe.cfg 
sudo systemctl enable nrpe
sudo systemctl restart nrpe
sudo systemctl restart docker
docker start apache