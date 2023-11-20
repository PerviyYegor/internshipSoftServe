#!/bin/bash

sudo yum -y install epel-release
sudo yum install nano  nagios nagios-plugins-{load,http,users,procs,disk,swap,nrpe,uptime} -y
sudo yum install -y nrpe
sudo systemctl start nagios
sudo systemctl enable nagios
sudo systemctl enable httpd
sudo htpasswd -c /etc/nagios/passwd nagiosadmin
sudo sed -i 's/SELINUX=permissive/SELINUX=disable/' /etc/selinux/config
sudo setenforce 0

sudo sh -c " echo 'cfg_file=/etc/nagios/servers/remote-server.cfg' >>/etc/nagios/nagios.cfg"

sudo mkdir /etc/nagios/servers

sudo mv /home/vagrant/remote-server.cfg  /etc/nagios/servers/remote-server.cfg
sudo chmod 755 /etc/nagios/servers/remote-server.cfg
sudo chown root:root /etc/nagios/servers/remote-server.cfg

sudo sed -i 's/Require ip 127.0.0.1/#Require ip 127.0.0.1/' /etc/httpd/conf.d/nagios.conf
sudo systemctl restart httpd

sudo sh -c "echo "allowed_hosts=127.0.0.1,192.168.5.10,192.168.7.10,192.168.10.10">>/etc/nagios/nrpe.cfg"
sudo systemctl enable nrpe
sudo systemctl start nrpe

sudo nagios -v /etc/nagios/nagios.cfg
sudo systemctl restart nagios
