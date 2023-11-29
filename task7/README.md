# Task: Launch a pod on Minikube with Prometheus that will monitor the status of Docker from task #4 and the VM from task #3

# Prerequisites:
 - Ensure that you have installed git, Minikube, and Docker locally.

1. Clone the repository and change the directory:
    ```
    git clone https://github.com/PerviyYegor/internshipSoftServe
    cd task7
    ```

2. Start EC2 instances using the scripts and configs from `/task3-aws` and `/task4-aws`. 
If you want to monitor other IPs, comment out the execution of `/task7/prometheusConfScript.sh`  in the file `/task7/startPrometheusInMinikube.sh` on line 4. 
Create your own `prometheus.yml` file in the `/task7/files` directory following the template `prometheus-template.yml`.

3. Execute the script `task7/startPrometheusInMinikube.sh` in the task7 directory:
    ```
    chmod +x ./startPrometheusInMinikube.sh
    ./startPrometheusInMinikube.sh
    ```
Wait for the process to complete.

4. The last output of the script should provide a local URL address with forwarding ports from Minikube. 
Copy and paste this URL into your browser to check connections to EC2 instances in the target Prometheus section.
Note: Do not close terminal session until you want to have access to Prometheus service from outside (your browser)

That's all. Thank you for your attention!
