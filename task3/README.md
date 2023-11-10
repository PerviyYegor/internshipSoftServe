Task: Launch a VM and install WordPress using Terraform and Ansible.

0. Git clone repository with completed tasks
    ```
    git clone https://github.com/PerviyYegor/internshipSoftServe
    ```
1. To start, make sure to update the local VM IP in the `/task3/machinesIP.yaml` file to a free IP within your network under the `vagrantWordpress` section. And configure credentials to DB in `task3/ansible-playbook/wordpress-playbook/roles/mysql/defaults/main.yml`.

2. Initiate the creation of the VM with pre-installed and pre-configured WordPress using the following commands:
    ```
    task3/terraform init
    task3/terraform plan
    task3/terraform apply
    ```
3. After executing the commands above, Terraform will trigger Vagrant with the terraform-vagrant provider to create the VM using the necessary Vagrantfile.
4. Vagrant, in turn, will invoke Ansible through the Ansible plugin for Vagrant to configure the VM for WordPress installation. This includes setting up MySQL, PHP, WordPress, and establishing a connection to the database.
5. Once Ansible has completed its configuration within Vagrant (in Terraform), you'll receive a notification, and your WordPress setup will be accessible at the IP address specified in step 0.

That's it! Enjoy using your WordPress setup.