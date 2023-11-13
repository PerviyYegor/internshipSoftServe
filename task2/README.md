### Task: Redirect Traffic between Subnetworks (Centos/RHEL 6)

To complete this task, a Vagrantfile has been created to set up two virtual machines in different subnetworks. The first machine is configured with an NGINX server through a bash script, sharing an HTML page accessible via `192.168.1.10:81` on the private network. The second machine, after setup, redirects traffic using iptables to the first machine, using `192.168.2.10:80`.

Follow these steps to test the setup:

1. **Clone Repository and Navigate to Task Directory:**
   ```bash
   git clone https://github.com/PerviyYegor/internshipSoftServe
   cd task2
   ```

2. **Start Infrastructure Creation with Vagrant:**
   Run the following command to initialize the virtual machines.
   ```bash
   vagrant up
   ```
   Wait for the setup to complete.

3. **Check Redirected Site Content:**
   Once the setup is complete, access the redirected machine's IP in your host machine's browser to view the site content.

4. **(Optional) Modify Site Content:**
   You can update the site by replacing the `index.html` file in the `task2/fileSamples` directory before performing step 2.

That's it! Thank you for your attention, and best of luck with the task.