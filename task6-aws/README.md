Task: Launch a EC2 AWS with Prometheus that will monitor status of the docker from task #4 and the VM from task #3

Change of the previous tasks: To complete this task, I upgraded the directories of task3 and task4 by adding configuration for Prometheus metrics export. In task 3 configuration of Prometheus exporter located in ansible roles `mysql-exporter` and `node-exporter`. In task 4 there is a directory with all necessary for prometheus configuration in `task4-aws/dockerInVMPart/MonitoringStart`

To monitor with Prometheus the container with Apache in the EC2 from task 4 and the EC2 with Apache from task 3, you should follow these steps:

1. Clone the repository and change the directory:
   ```bash
   git clone https://github.com/PerviyYegor/internshipSoftServe
   cd task6-aws
   ```

2. Make sure you started EC2s from the previous tasks in `/task3-aws` and `/task4-aws`. If not, you can start them by following the guides in these directories.

3. (Optional) You can check readiness of your machines by execute script what make prometheus config file
 ```
 ./prometheusConfScript.sh
```
If ip files exist you can check conf file in VMPart/files/prometheus.yml but to be sure better check state with terraform or manually in AWS dashboards

1. After this, you can start creation of EC2 with prometheus monitoring using the command:
   ```bash
   terraform apply
   ```

2. Wait a few minutes, and you can check the state of your machines and check connection beetwen monitoring host and monitoring servers by entering the following URL in your browser: `http://<ip-prometheus-from-ip.txt>:9090/targets`

That's it, now you can monitor your apache container in the VM and the VM with wordpress and mysqlDB. Thank you, and have a good day! :)