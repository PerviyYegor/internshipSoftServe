Task: Launch a VM in AWS and install WordPress using Terraform and Ansible in EC2.
Requirenments: registered connection to AWS with awscli utility, Ansible and Terraform

0. Git clone repository with completed tasks
    ```
    git clone https://github.com/PerviyYegor/internshipSoftServe
    cd task3-aws
    ```

1. Initiate the creation of the VM with pre-installed and pre-configured WordPress using the following commands:
    ```
    cd terraform-configs/
    terraform init
    terraform plan
    terraform apply
    cd ..
    ```
2. After executing the commands above, Terraform will trigger AWS to create resources like ec-2 instance, network etc. After success raise of aws infrastacture you can check public ip of your machine with execution of:
    ```
    cd terraform-configs/
    terraform output -raw public_ip
    cd ..
    ```

3. You can also check connect to ec2 machine with ansible with execution folow commands (optional):
```
cd andsible-playbook
ansible -m ping all
cd..
```
4. Finally to configure your ec2 like wordpress host with Prometheus monitoring you should start Ansible with exectuion:
```
cd andsible-playbook
ansible-playbook  playbook.yml
cd ..
```
5. After complition of ansible job you can check your wordpress on URL (from step 2) `http://<ip-machine>` also your prometheus metrics on url `http://<ip-machine>:9100` and mysql metrics `http://<ip-machine>:9104`
   
That's it! Enjoy using your WordPress setup on AWS infrastacture.