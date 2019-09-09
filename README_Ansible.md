# Using Ansible to install OpenVidu

## Prerequisites

### Clone the repo

`git clone https://github.com/OpenVidu/openvidu-pro-clustering.git`

### Local Machine

You need Ansible installed on your laptop or wherever you are running this playbook. To install Ansible run the following commnads:

```
$ sudo apt-add-repository -y ppa:ansible/ansible
$ sudo apt-get update 
$ sudo apt-get install -y ansible
```

Besides you need to install this role for Docker:

`sudo ansible-galaxy install -p /etc/ansible/roles geerlingguy.docker`

## Instances

You need 1 instance for OpenVidu Server and at least 1 more for Kurento Media Server with a minimum of 2 cpus and 8gigs of RAM. All instances should be accesible by SSH from your laptop.

The instances (all of then) need Python to be installed.

`$ sudo apt update; sudo apt install -y python`

## Security Groups

* OpenVidu Pro Server

  - 4443 TCP (OpenVidu Server listens on port 4443 by default)
  - 3478 TCP (coturn listens on port 3478 by default)

* Media Servers

  - 40000 - 65535 UDP (WebRTC connections with clients may be established using a random port inside this range)
  - 40000 - 65535 TCP (WebRTC connections with clients may be established using a random port inside this range, if UDP can't be used because client network is blocking it)
  - 8888 TCP (must only be accessible for OpenVidu Server Pro instance) (Kurento Media Server listens on port 8888 by default)

## DNS Server

It's highly recomended to use a DNS server to register a FQDN for the OpenVidu instance.

## Inventory

As you probably alredy know, Ansible uses an inventory file to know which instances connect to and how to configure then. The inventory is a YAML file looks like

```
---
all:
  hosts:
    openvidu-server:
      ansible_host: X.Y.Z.W
    media-server-1:
      ansible_host: X.Y.Z.1
    # media-server-2:
    #   ansible_host: X.Y.Z.2
    # ...
    # media-server-N:
    #   ansible_host: X.Y.Z.N
  vars:
      ansible_become: true
      ansible_user: USER
      ansible_ssh_private_key_file: /PATH/TO/SSH_public_key
  children:
    media:
      hosts:
        media-server-1:
      #   media-server-2:
      #   ...
      #   media-server-N:
    openvidu:
      hosts:
        openvidu-server:
```

You need to change:

  - `ansible_user`: the user you use to connect to the instances, i.e. Ubuntu Server Cloud uses _ubuntu_. If you've deployed those instances in OpenStack using Ubuntu Official Image, this will be the user. 
  - `ansible_ssh_private_key_file`: Path to the RSA private key you use to connect to your instances.
  - `X.Y.Z.W`: Public IP to connect to the instance.
  - `X.Y.Z.1`: Public IP to connect to the instance.

Uncomment the lines if you're using more than one Media Server

## Group vars

In `group_vars/all` file you will find all the parameters we use to configure the infrastructure. Read all of then carefully as they don't have a default value.

For futher information check out https://openvidu.io/docs/reference-docs/openvidu-server-params/

## Deployment

First time you connect to an instance through SSH, it will ask you to confirm the instance fingerprint, so try to login into all the instances to accept the fingerprint so Ansible can do the job.

`ssh -i /PATH/TO/SSH_public_key USER@INSTANCE`

Replace the parameters by the apropiates values. Then you maybe want to check that Ansible can access the instances:

`ansible -i inventory.yml -m ping all`

This command will perform a _ping_ command in the instances, so we're now sure you have access to the instances and the inventory file is fine.

Once you have completed all the information and parameters you can launch the playbook by running:

`ansible-playbook -i inventory.yaml play.yaml`

After a while, you'll see this lines showing OpenVidu Server Pro is up and ready:

```
*********************************************************
 TASK [check-app-ready : check every 60 seconds for 10 attempts if openvidu is up and ready] 
*********************************************************
FAILED - RETRYING: check every 60 seconds for 10 attempts if openvidu is up and ready (10 retries left).
FAILED - RETRYING: check every 60 seconds for 10 attempts if openvidu is up and ready ( 9 retries left).
ok: [openvidu-server]

*********************************************************
 PLAY RECAP 
*********************************************************
kurento-server-1           : ok=21   cshanged=18   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
kurento-server-2           : ok=21   changed=18   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
openvidu-server            : ok=53   changed=43   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   
```

Once it's installed you can access the service through the URL: _https://YOUR_DNS_NAME/inspector_ replace **YOUR_DNS_NAME** by your FQDN. Also, we provide a full featured Kibana Dashboard in _https://YOUR_DNS_NAME/kibana_ where you can check for performance and useful statics.

## Troubleshooting

If you get stuck deploying this playbooks remember we're here to help you. So please, when you open a new issue provide the full Ansible output log and, if you were able to deploy OpenVidu Server, please provide also the log from the server:

`sudo journalctl -u openvidu`

this content could be big. Check if you can spot any failure to help us to help you.
