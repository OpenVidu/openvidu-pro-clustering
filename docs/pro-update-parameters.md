# Update parameters OpenVidu Pro

How to update and add new parameters to OpenVidu Pro

## Update or Add OpenVidu Pro Configuration Parameters

Update OpenVidu Pro parameters has the same procedure to be updated in all kind of OpenVidu Pro deployments (AWS and On Premise). The most reliable way
to change parameters of an OpenVidu Pro deployment is to change it directly with ssh:

1. Ssh to OpenVidu Server machine:

    You will need the private rsa key to access to the *OpenVidu Server* via ssh. If you've deployed OpenVidu Pro On Premise, you should have this key used in the installation process with Ansible.

    In AWS CloudFormation, when you filled up the form, one of the parameters was an rsa key to grant you access to the instance. You’ll need that key and the instance’ IP address.

    For example, if your key file is called mi-key.pem and the instance has an IP address like 12.13.14.15 you need to run this command from the shell:

    ```
    ssh -i mi-key.pem ubuntu@12.13.14.15ç
    ```

    and then you will see something like this:

    ```
    Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-1077-aws x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage

    Get cloud support with Ubuntu Advantage Cloud Guest:
        http://www.ubuntu.com/business/services/cloud

    54 packages can be updated.
    25 updates are security updates.

    New release '18.04.2 LTS' available.
    Run 'do-release-upgrade' to upgrade to it.


    Last login: Mon Apr 22 14:44:42 2019 from 85.58.224.197
    To run a command as administrator (user "root"), use "sudo <command>".
    See "man sudo_root" for details.

    ubuntu@ip-172-31-35-250:~$
    ```

2. Update application.properties:

    From here, go to `/opt/openvidu/`.:

    ```
    cd /opt/openvidu/
    ```

    In this directory there is a file called `application.properties`. You can use it to edit this file a program called `nano`:
    To Update it:

    `sudo nano /opt/openvidu/application.properties`

    Modify or add the properties you want and Save the file by pressing `CTRL+X` and after that press `Y` to confirm that you want to save the content.

3. Restart OpenVidu Server:

    To restart OpenVidu Server just enter this command:

    ```
    sudo systemctl restart openvidu
    ```

    To check that everything is fine, just check the log by entering:

    ```
    journalctl -n 100 -u openvidu | cat
    ```

    This will print the last 100 lines of the OpenVidu Pro Server Log





