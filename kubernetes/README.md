# OpenVidu Pro Kubernetes

This guide explains how to deploy OpenVidu Pro in Kubernetes.

## Clone This Repo

`$ git clone https://github.com/OpenVidu/openvidu-pro-clustering`

Change to this directory

`$ cd openvidu-pro-clustering/kubernetes`

## Prerequisites

You'll need access to a Kubernetes cluster. We've been working with Kubernetes 1.15 and 1.16 but it should work with any cluster version higher than 1.10.

Also, you'll need `kubectl` command in your **PATH**. To install it, follow [this](https://kubernetes.io/docs/tasks/tools/install-kubectl/) guide.

### Helm and Ingress

You need an Ingress controller running on your cluster. You can install one using Helm.

* Install Helm

https://helm.sh/docs/intro/quickstart/

* Install Ingress

https://kubernetes.github.io/ingress-nginx/deploy/

In AWS, the ingress controller will create a LoadBalancer, configure your DNS provider to point to this URL.

In GCE, the ingress controller will create a public IP you can use with https://nip.io. 

### Storage

Elasticsearch needs to create a volume to storage the index and other data. If you don't have **Storage Class** configured in your infrastructure do the following

* AWS

```
$ cat>storage-class.yaml<<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  iopsPerGB: "10"
  fsType: ext4
EOF

$ kubectl apply -f storage-class.yaml
```

* GCE

```
$ cat>storage-class.yaml<<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/gce-pd
parameters:
  type: io1
  iopsPerGB: "10"
  fsType: ext4
EOF

$ kubectl apply -f storage-class.yaml
```

## Security

OpenVidu needs to launch and drop Media nodes in your Kubernetes cluster. We need to grant permissions to perform this actions. Run this command to allow OpenVidu to launch and drop Media nodes.

`$ kubectl apply -f openvidu-role-user.yaml`

## OpenVidu Pro Password

To install OpenVidu Pro you need a password, please contact us at openvidu@gmail.com to obtain one.

Once you've the password, code it into base64 running this command:

`$ echo -n 'YOUR_PASSWORD' | base64`

Replace _YOUR_PASSWORD_ with the password you've received. The output of that command should look like

`WU9VUl9QQVNTV09SRA==`

Copy the string and paste in `openvidu-pro-password.yaml` file, then run this command:

`$ kubectl apply -f openvidu-pro-password.yaml`

## ElasticSearch and Kibana

OpenVidu Pro brings the power of Elastic Stack. Events and monitoring stats are sent to Elasticsearch and can be visualized through Kibana.

To deploy run this command:

`$ kubectl apply -f Elasticsearch-Kibana/`

## OpenVidu Pro Configuration

All the configuration section is in `openvidu-server.yaml` file. More information about how to configure OpenVidu can be found [here](https://openvidu.io/docs/reference-docs/openvidu-server-params/).

OpenVidu Pro needs ingress to work. Ingress will configure a LoadBalancer in your cluster, you should create an entry in you DNS provider pointing to this value. This is because ingress uses DNS names to identify the HTTP requests and associates it with the service. 

Saying that, replace the values in the ingress manifest inside the `openvidu-server.yaml` file with your own FQDN.

Once you've performed all the changes and you're happy with the configuration, run this command:

`$ kubectl apply -f openvidu-server.yaml`

After a few seconds you can run

`$ kubectl get pods`

to see something like this

```
NAME                                                 READY   STATUS    RESTARTS   AGE
pod/es-cluster-0                                     1/1     Running   0          13m
pod/kibana-556fdb8fbf-cfvhk                          1/1     Running   0          13m
pod/kms-kerf                                         1/1     Running   0          4m7s
pod/openvidu-server                                  1/1     Running   0          5m41s
......
```

Now, access the OpenVidu Dashboard with a browser pointing to https://YOUR_DOMAIN/inspector/

Fill up the password field with the `OPENVIDU_SECRET` value you setted up in the template.

## Troubleshooting

If you find any problem, please, do not hesitate to ask for help attaching the logs

`kubectl logs openvidu-server`

and any other information you think can be useful for us.

openvidu@gmail.com