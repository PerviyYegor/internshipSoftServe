# Task: Configure Grafana dashboard for Prometheus in minikube
# Prerequisites:
 - Ensure that you have installed git, Minikube, helm, and Docker locally. And started Prometheus in Minikube with guide from `/task7`

1. Clone the repository and change the directory:
   ```bash
   git clone https://github.com/PerviyYegor/internshipSoftServe
   cd task8
   ```

2. Execute the script `task7/startPrometheusInMinikube.sh` in the task7 directory:
    ```
    chmod +x ./startGrafanaInMinikube.sh
    ./startGrafanaInMinikube.sh
    ```
Wait for the process to complete.

4. The last output of the script should provide a local URL address with forwarding ports from Minikube. 
Copy and paste this URL into your browser to start configure your Grafana dashboards. (you can try templates: 3662, 1229, 7362, 1860)
Note: Do not close terminal session until you want to have access to Grafna service from outside (your browser)

That's it, now you can monitor your apache container in the VM and the VM with wordpress and mysqlDB with Grafana service. Thank you, and have a good day! :)