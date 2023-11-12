Task: Launch a Docker container with an Apache server using Terraform.

To initiate the Docker container running Apache, follow these steps:

1. Modify the contents of the `siteExample` directory in `/task4`. By default, it's set from https://github.com/georgebrata/html-templates.
2. Modify the path to the repository in the Terraform configuration at `/task4/main.tf` within the `docker_container` resource in the `volumes` section).
3. Start the Docker container deployment using Terraform by executing the following commands in the root directory:
    ```
    terraform init
    terraform plan
    terraform apply
    ```
4. After approximately a minute, you can access your site at `localhost:8080` (Note: You can change the port in the Terraform configuration at `/task4/main.tf` within the `docker_container` resource in the `ports` section).

That's it! Good luck with your deployment :)