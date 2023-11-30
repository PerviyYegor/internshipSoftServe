Task: Launch a Docker container on an AWS EC2 instance with an Apache server using Terraform.

To initiate the Docker container running Apache on AWS EC2, follow these steps:

1. Make sure you have a registered connection to AWS with the awscli utility, and Terraform installed. Clone the Git repository with the following command:
   ```
   git clone https://github.com/PerviyYegor/internshipSoftServe
   cd task4-aws
   ```

2. (Optional) Modify the contents of the `siteExample` directory in `task4-aws/ansible-playbook/roles/docker/files`. By default, it's set to https://github.com/tailwindtoolbox/Landing-Page.

3. Start the EC2 creation with Docker container using Terraform by executing the following commands in the root of the `task4-aws` directory:
    ```
    cd terraform-configs
    terraform init
    terraform plan
    terraform apply
    cd ..
    ```

4. After the creation of EC2 in AWS, Terraform will create resources in your AWS account: instance, security groups, pair keys, vpc and etc. Also it will create new private key to connect to remote EC2, this key is located in `/task4-aws/ssh-key.pem` also you can check public ip of your machine with execution of:
    ```
    cd terraform-configs/
    terraform output -raw public_ip
    cd ..
    ```

4. Finally to configure your ec2 like docker host with apache server in docker and Prometheus monitoring you should start Ansible with exectuion:
    ```
    cd andsible-playbook
    ansible-playbook  playbook.yml
    cd ..
    ```
    NOTE: execution of ansible-playbook immediately after creation of EC2 can return error of connection to 22 port, wait 1-2 minutes to try again.

5. After complition of ansible job you can check your apache container on URL (from step 4) `http://<ip-machine>` also your prometheus metrics on url `http://<ip-machine>:9100` and docker engine metrics `http://<ip-machine>:9323`
   
That's it! Enjoy using your apache in docker container setup on AWS infrastacture. :)
