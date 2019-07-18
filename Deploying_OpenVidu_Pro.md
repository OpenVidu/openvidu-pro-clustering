# Deploying OpenVidu Pro

* * *

OpenVidu Pro is available through **Amazon Web Services** (you will need an [AWS account](https://portal.aws.amazon.com/billing/signup?redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start))

### 1) Steps towards configuration

##### A) Access to the console of AWS Cloud Formation

[Go to CloudFormation](https://console.aws.amazon.com/cloudformation)

##### B) Click on _Create Stack_

![](/img/docs/deployment/CF_newstack.png)

##### C) Option _Specify an Amazon S3 template URL_ with the following URL 

`https://s3-eu-west-1.amazonaws.com/aws.openvidu.io/cfn-OpenViduServerPro-cluster-latest.yaml` 

![](/img/docs/deployment/CF_url.png)

### 2) Configure your OpenVidu Server Pro

Fill each section of the form with the appropriate values as stated below.

#### Stack name

The name of your deployment

#### SSL Certificate Configuration

This is the kind of certificate you will be using in your deployment. Three different options are offered: 

- **selfsigned**: use a selfsigned certificate. This options is meant for testing and developing environments. Leave the rest of the fields with their default value

- **letsencrypt**: use an automatic certificate by Let's Encrypt. This way you don't have to worry about providing your own certificate. You simply have to enter an email account where Let's Encrypt will send its messages, your fully qualified domain name and one AWS Elastic IP for the same region you selected before ([allocate one if you don't have it](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html#using-instance-addressing-eips-allocating)). Of course, **you will need to register this Elastic IP in your DNS hosting service and associate it with your fully qualified domain name**. Only after this association between the Elastic IP and your domain name is effective your deployment with Let's Encrypt will work fine.

- **owncert**: use your own certificate. You must provide one AWS Elastic IP for the same region you selected before ([allocate one if you don't have it](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html#using-instance-addressing-eips-allocating)), and your public certificate and private key, both accessible through uris (an Amazon S3 bucket is the best way to do it). Leave the default values for *Email* and *Fully qualified domain name* fields.

#### OpenVidu Configuration

These fields respectively configure the following [system properties](https://openvidu.io/docs/reference-docs/openvidu-server-params/) of OpenVidu Server: `openvidu.secret`, `openvidu.recording.public-access`, `openvidu.recording.notification`, `openvidu.streams.video.max-recv-bandwidth`, `openvidu.streams.video.min-recv-bandwidth`, `openvidu.streams.video.max-send-bandwidth`, `openvidu.streams.video.min-send-bandwidth`


#### Openvidu Security Group

These fields allow you to limit the IPs that will be able to connect to OpenVidu Server Pro. 

> **WARNING**: be careful when limiting these IP ranges
 
  > - **Port 4443 access Range**: OpenVidu Server Pro REST API and client access point. This should be set to `0.0.0.0/0` if you want any client to be able to use your deployment 

  > - **Port 3478 access Range**: TURN server port. This should be set to `0.0.0.0/0` if you want any client to be able to use your deployment, as you never know which user might need a TURN connection to be able to send and receive media 

  > - **SSH Port access Range** can be limited as you want, as it provides SSH access to the server with the proper private key through port 22 

  > - **HTTPS and HTTP (ports 443 and 80) access Range**: HTTPS access range will determine the directions able to connect to Kibana dashboard. If you are using Let's Encrypt SSL configuration, set HTTP access range to `0.0.0.0/0`, as Let's Encrypt will need to access your server through port 80. 

  > - **UDP Port access Range** and **TCP Port access Range**: limits the clients that will be able to establish TCP and UDP connections to your OpenVidu Server Pro. So again, if you want to provide service to any client these should be set to `0.0.0.0/0` 

  > - **MinOpenPort** and **MaxOpenPort**: determine what ports will be available to establish the media connections, so the generous default value is a good choice. If you change the values leaving out any of the previously stated ports, the deployment may fail

#### Kibana Dashboard Set the user and password for accessing Kibana dashboard.

#### Other parameters 

Choose the size of your instance (see [OpenVidu performance FAQ](https://openvidu.io/docs/troubleshooting/#9-which-is-the-current-status-of-openvidu-on-scalability-and-fault-tolerance)) and a Key Pair ([create one if you don't have any](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)).

You are ready to go. Click on **Next** 🡆 **Next** 🡆 **Create stack** to finally deploy your OpenVidu Server Pro.

### 3) Connecting to your OpenVidu Server Pro

Now you just have to wait until Stack status is set to `CREATE_COMPLETE`. Then you will have a production-ready setup with all the advanced features provided by OpenVidu Pro.

> If status reaches `CREATE_FAILED`, check out [this FAQ](https://openvidu.io/docs/troubleshooting/#13-deploying-openvidu-in-aws-is-failing).

To connect to **OpenVidu Inspector** and the **Kibana dashboard**, simply access `Outputs` tab. There you will have both URLs to access both services.


To consume [OpenVidu REST API](https://openvidu.io/docs/reference-docs/REST-API/), use URL `https://OPENVIDUPRO_PUBLIC_IP:4443`. For example, in the image above that would be `https://ec2-34-246-186-94.eu-west-1.compute.amazonaws.com:4443`

>Regarding the compatibility of **openvidu-browser** and **server SDKs** (REST API, openvidu-java-client, openvidu-node-client), use the same version numbers as stated for openvidu-server in [Releases page](https://openvidu.io/docs/releases/). For example, for OpenVidu Pro 2.9.0, use the artifact versions indicated in [2.9.0 release table](https://openvidu.io/docs/releases#290)

