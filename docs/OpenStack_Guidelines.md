# OpenStack Guidelines

## Introduction

You can use this notes as an example of how to deploy OpenVidu in your infrastructure but we know every datacenter is unique.

## Prerequisites

We assume you've experience with Linux terminal and managing OpenStack from the shell.

Please, load the OpenStack Environment veriables before running the commands.

## Security groups

We've created two security groups, one for OpenVidu Server and the other one for the media servers.

### OpenVidu server

Create the security group.

`$ openstack security group create openvidu-server`

Add the rules.

```
$ openstack security group rule create --protocol tcp --dst-port 22 openvidu-server
$ openstack security group rule create --protocol tcp --dst-port 80 openvidu-server
$ openstack security group rule create --protocol tcp --dst-port 443 openvidu-server
$ openstack security group rule create --protocol tcp --dst-port 4443 openvidu-server
$ openstack security group rule create --protocol tcp --dst-port 3478 openvidu-server
```

_Note_: It's probably you already have a security group for SSH, HTTP and HTTPS.

### Media servers

We need this security group:

`$ openstack security group create media-servers`

And open this ports:

```
$ openstack security group rule create --protocol tcp --dst-port 22 openvidu-server
$ openstack security group rule create --protocol tcp --dst-port 80 openvidu-server
$ openstack security group rule create --protocol tcp --dst-port 443 openvidu-server
$ openstack security group rule create --protocol tcp --dst-port 40000:65535 testing
```

We'll need access to port 8888 from the OpenVidu Server. But we need to know the private IP of the instances first.

## Volumes

We recomend to use volumes for the instances so you can expand volumes sizes if you need for example.

So, create the volume for OpenVidu:

```
openstack volume create \
  --image "Ubuntu Xenial" \
  --size 100 \
  --availability-zone nova \
  openvidu-server
```

And all the volumes for media servers:

```
MAX=N
for volume in $(seq 1 $MAX)
do
openstack volume create \
  --image "Ubuntu Xenial" \
  --size 100 \
  --availability-zone nova \
  media-server-$volume 
done
```

With _N_ the number of media servers you want to create. In this example we're using the image "Ubuntu Xenial", OpenVidu and media servers work with Xenial, check out which is the image name for your infraestructure.

A size of 100GB is enough for the instances.

## Instances

Once the volumes are ready we can attach them to the instances:

For the OpenVidu server

```
openstack server create \
  --flavor m1.large \
  --volume openvidu-server \
  --nic net-id=NETWORK \
  --key-name KEY_NAME \
  --user-data user_data.cfg \
  --security-group openvidu-server \
  openvidu-server
```

And for the media servers

```
for instance in $(seq 1 $MAX)
do
openstack server create \
  --flavor m1.large \
  --volume media-server-$instance \
  --nic net-id=NETWORK \
  --key-name KEY_NAME \
  --user-data user_data.cfg \
  --security-group media-servers \
  media-server-$instance
done
```

We're using a **m1.large** flavor which has 4vcpus and 8Gigs RAM.

You've to replace the network and the key name by the appropiate values. The network we're using can use floating IPs.

We use a little `user_data.cfg` script to install Python because we need it for Ansible:

```
#!/bin/bash
# This script will do some pre-config
# before it can be privisioned by
# ansible

# Installing python
apt-get update \
  && apt-get install -y python

exit 0
```

## Updating security group

Now we're going to restrict access to port 8888 of media servers to OpenVidu server. 

First, we need to locate which private IP our OpenVidu server is using because we are going to limit access to port 8888 of media servers to this source IP.

`$ openstack server show openvidu-server -c addresses`

We'll see something like this:

```
+-----------+-------------------+
| Field     | Value             |
+-----------+-------------------+
| addresses | NETWORK=10.1.1.7  |
+-----------+-------------------+
```

Remember, NETWORK is **your** network name. With that IP we update the rules of the security group:

`$ openstack security group rule create --remote-ip 10.1.1.7 --protocol tcp --dst-port 8888 media-servers`

## Assigning Floatings IPs

**Note**: this is optional and depends on your deployment.

To assing the floating IP `A.B.C.D` to the instance `openvidu-server` run this command:

`openstack server add floating ip openvidu-server A.B.C.D`

Keep going with the rest of the instances.

**Note**: floating IP does not necesarily means open to the Internet. Could be an IP class C within your local network.

## Running Ansible

Now, you can refer to this [documentation](https://openvidu.io/docs/openvidu-pro/deploying-openvidu-pro/#deploying-openvidu-pro-on-premise) to deploy the software in the infrastructure.

In the `inventory.yml` file replace the values by the floating IPs.

And in the `group_vars/all` use the private IPs of the media servers in this line:

```
# A comma separate list of IPs from the KMS instances
# i.e. 192.168.0.5,192.168.0.6
kms_ips: 
```


