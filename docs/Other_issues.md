# Other Issues

## User and group

This playbook asume the **user/group ubuntu/ubuntu** exists in the system, if this is not your case, set up the apropiate values in `group_var/all` file:

```
# Cloud provider like AWS or OpenStack set up
# ubuntu user without password. Put your own user
# if you're using another provider or bare metal
openvidu_user: ubuntu
openvidu_group: ubuntu
```
