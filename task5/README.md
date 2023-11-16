**Task: Launch a VM with Nagios that will monitor the status of the Docker from task #4 and the VM from task #3**

Change of the previous tasks: To complete this task, I upgraded the directories of task3 and task4 by adding configuration for NRPE. In task 4, I added the ability to start Docker in the Vagrant VM with a static IP of 192.168.5.10.

To monitor with Nagios the container with Apache in the VM from task 4 and the VM with Apache from task 3, you should follow these steps:

1. Clone the repository and change the directory:
   ```bash
   git clone https://github.com/PerviyYegor/internshipSoftServe
   cd task5
   ```

2. Make sure you started VMs from the previous tasks in `/task3` and `/task4`. If not, you can start them by following the guides in these directories.

3. (Optional) If you changed the VM's IP in `/task3` or `/task4`, update the IP in the file `/task5/nagiosInstall.sh` on line 22 and in the file `/task5/templates/remote-server.cfg` in the host sections.

4. After this, you can start your VM with Nagios monitoring using the command:
   ```bash
   vagrant up
   ```

5. Wait a few minutes, and you can check the state of your machines by entering the following URL in your browser: `http://<ip-nagios>/nagios/` (by default, the IP is 192.168.7.10; you can change it in `/task5/Vagrantfile`).

That's it. Thank you, and have a good day! :)