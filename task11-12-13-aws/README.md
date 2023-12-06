Tasks: 11: Try to create your own AMI with pre-installed packages using Packer(HashiCorp)
       12: For Prometheus from task 6, configure ec2_sd_config(Prometheus should automatically discover ec2 instances and scrape them)Use IAM role for this task
       13:Deploy Alertmanager either in VM or minikube. Create an alert rule, which will notify you in Telegram(or different receiver by your choise)

# Packer
Make sure you have installed Packer and configured connection to aws with aws-cli
To create you own AMI with Prometheus and Alertmanager from files you should folow this steps:
1. Clone the repository and change the directory:
   ```bash
   git clone https://github.com/PerviyYegor/internshipSoftServe
   cd task11-12-13-aws/packer
   ```
2. Install dependencies of Packer and start build AMI with execution command:
   ```
   packer init --upgrade
   packer build packer.pkr.hcl
   ```
3. After success build of image you can check it in your AWS Console in AMIs section
   NOTE: you can change configurations (region, instance type, etc.) of AMI in task11-12-13-aws/packer/packer.pkr.hcl file

# Terraform start custom AMI with preconfigure Prometheus and autodiscover of instances
To start previously created AMI you should execute next commands:
1. Change directory to `terraform-configs` directory
    If you do it from Packer directory execute ```cd ../terraform-configs```
    If from root of project execute ```cd terraform-configs```
2. Create your own telegram bot to get alerts from AlertManager (you can do it here `https://t.me/MiddlemanBot`) and past your tag to ```terraform-configs/files/alertmanager.yml``` instead of placeholder `<YOUR_TAG_HERE>'
3. Install dependencies and start ec2 with custom AMI
   ```
   terraform init
   terraform apply
   ```
   Note: make sure you started ec2's from `task3-aws` and `task4-aws` unless Prometheus have no machines to monitoring if you didn't start any others ec2's in defauld vpc and subnet with exporters, then you should change tags in ```terraform-configs/files/prometheus.yml```
4. Check work of Prometheus and AlertManager with copy and past IP from last row of terraform output to browser with ports `9090` for Prometheus webUI and  `9093` for Alertmanager webUI.
5. To check work of Telegram notifications you can stop NodeExporter or any other exporters in targets instances via ssh and wait 2-3 minutes to get message from telepush bot.

That is it, enjoy this configs and do whatever you want with it :)