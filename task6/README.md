Task: Launch a VM with Prometheus that will monitor status of the docker from task #4 and the VM from task #3

Change of the previous tasks: To complete this task, I upgraded the directories of task3 and task4 by adding configuration for Prometheus metrics export. In task 3 configuration of Prometheus exporter located in ansible roles `mysql-exporter` and `node-exporter`. In task 4 there is a script in `task4/vagrantVM/prometheusAgentInstall.sh`

To monitor with Prometheus the container with Apache in the VM from task 4 and the VM with Apache from task 3, you should follow these steps:

1. Clone the repository and change the directory:
   ```bash
   git clone https://github.com/PerviyYegor/internshipSoftServe
   cd task6
   ```

2. Make sure you started VMs from the previous tasks in `/task3` and `/task4`. If not, you can start them by following the guides in these directories.

3. (Optional) If you changed the VM's IP in `/task3` or `/task4`, update the IP in the prometheus configuration file `/task6/files/prometheus.yml`.

4. After this, you can start your VM with Prometheus monitoring using the command:
   ```bash
   vagrant up
   ```

5. Wait a few minutes, and you can check the state of your machines and check connection beetwen monitoring host and monitoring servers by entering the following URL in your browser: `http://<ip-prometheus>:9090/targets` (by default, the IP is 192.168.6.10; you can change it in `/task6/Vagrantfile`).

That's it, now you can monitor your apache container in the VM and the VM with wordpress and mysqlDB. Thank you, and have a good day! :)