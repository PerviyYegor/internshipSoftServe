Task: Launch a Docker container on an AWS EC2 instance with an Apache server using Terraform.

To initiate the Docker container running Apache on AWS EC2, follow these steps:

1. Make sure you have a registered connection to AWS with the awscli utility, and Terraform installed. Clone the Git repository with the following command:
   ```
   git clone https://github.com/PerviyYegor/internshipSoftServe
   ```

2. (Optional) Modify the contents of the `siteExample` directory in `/task4-aws`. By default, it's set to https://github.com/georgebrata/html-templates.

3. Start the EC2 creation with Docker container using Terraform by executing the following commands in the root of the `task4-aws` directory:
    ```
    cd task4-aws
    terraform init
    terraform plan
    terraform apply
    ```

4. After the creation of EC2 in AWS, Terraform will deploy the contents of the `dockerInVMPart` directory to the remote instance and execute necessary scripts to start the Apache container and set up Prometheus monitoring for both the container and the EC2 instance.
NOTE: there is can be troubles with execution of script and docker start because of permission. If this is your case just run ```terrafrom apply``` again, it might fix problem.
5. After approximately a minute, you can access your site at `http://<ip-from-ip.txt>:80`. Note: You can change the port in the Terraform configuration at `/task4-aws/dockerInVMPart/main.tf` within the `docker_container` resource in the `ports` section.

6. To access Prometheus monitoring, visit `http://<ip-from-ip.txt>:9100` to check the EC2 instance state and `http://<ip-from-ip.txt>:9323` to check the Apache container state and Docker socket in general.

That's it! Good luck with your deployment :)
