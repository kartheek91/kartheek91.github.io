---
title: Docker Container Auto Restart Policies
layout: post
date: '2022-04-22 21:23:24'
tags: []
---

Hello all, today I will share my knowledge regarding docker and its restart policies. We have an application hosted in the **Nginx** container. We hosted all our applications in the Azure cloud provider. Usually, we will have patches to update the virtual machines. During this process, we might encounter restarting the virtual machines. Due to this, we will see that couple of containers will be in a stopped state

**Why and what is happening behind the scenes?**
When we try to start the container, it will have No as default. It will not start when the containers exist or when the docker daemon gets restarted.

***Docker*** provides restart policies to control whether your containers start automatically when they exit or when the docker daemon gets restarted. Please make note that restart policies will apply only to containers.

We can specify the restart policy using the --restart flag with the docker run command.


**Restart Policies**:

| Flag | Description
| -------- | -------- |
| no     | Do not automatically restart the container(the default).     |
| on-failure     |Restart the container if it exists due to an error, which manifests as a non-zero exit code.     |
| unless-stopped     |Restart the container unless it is explicitly stopped or Docker itself is stopped or restarted.     |
| always     |always restart the container if it stops.     |

Today we will focus on **unless-stopped**.

Now we will run the Nginx container without a restart policy.

` docker run -d -p 8080:80 --name nginx nginx`

![]({{ 'result1.PNG' | relative_url }})

Let's restart docker service

![]({{ 'res2.png' | relative_url }})

Now, let's check whether the existing container is running or not by using the following command.

```
docker ps -a
```

![]({{ 'result2.PNG' | relative_url }})

So the container is in exited state. We need to avoid this situation when we are deploying the same container in the production environment.

Let's see how we can make use of restart property with **unless-stopped**.

We need to start the container with this command
```
docker container run -d -p 8080:80 --name nginx --restart unless-stopped nginx
```
Let's restart docker service

![]({{ 'res2.png' | relative_url }})

Now we can check the status of the container 

![]({{ 'result4.PNG' | relative_url }})

So the container automatically gets restarted 27 seconds ago without any manual intervention.

**References**:

https://docs.docker.com/config/containers/start-containers-automatically/

Regards

***Kartheek Gummaluri***
