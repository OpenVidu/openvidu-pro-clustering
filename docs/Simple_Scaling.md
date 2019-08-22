# Simple Scaling

## Introduction

Media servers are running in an AWS AutoScaling Group. Which means that can be scaled to any number of media server you want to use.

**WARNING:** Keep in mind that as more media servers more expensive will be this solution.

## Changing cluster size

Go to AWS Dashboard -> AutoScaling Groups:

![](images/ASG1.png)

You'll see three values:

- **Desired Capacity**: Is the number of instances we want to keep up and running.
- **Min**: Is the minimum number of instances we want to keep up and running.
- **Max**: Is the maximum number of instances we want to keep up and running.

So, in example, if we want to stop the cluster we could set **Desired Capacity** and **Min** values to zero.

But, if we want to scale we must set **Desired Capacity** and **Max** values to the value we want.

![](images/ASG2.png)

Once we've made the changes we can shutoff the OpenVidu Server instances if we want to stop the cluster completely or reboot it for the server takes the changes in cluster size.

