---
title: Hands on Multi-Host Networking with Docker Overlay Driver
layout: post
date: '2021-06-13 12:41:31'
tags:
- Docker
- Ubuntu
---

Hi all, today we will learn about Multi-Host Networking with Docker Overlay Driver. The main idea is to make containers of different hosts talk to each other.

![]({{ 'multi-host-overlay.png' | relative_url }})

For making things simple, let's consider two nodes of different subnets. In each node, we will have SandBox installed with a bridge driver. Now VXLAN tunnel endpoint gets created, attached to the bridge. Now VXLAN tunnel gets created. It will act as an overlay network. It is a single Layer2 broadcast domain. 

So each container is attached to the virtual adapter to connect to the bridge driver. Let's say container 1 wants to connect to container two,  which are in different hosts. So, container one will create a virtual adapter and will attach it to the bridge driver. This bridge driver internally communicates via a virtual ethernet endpoint through a VXLAN tunnel. In this way, we can talk to container two from container one. We need to same to communicate vice-versa.

To make our hands dirty, we need to have two ubuntu virtual machines. Docker installed on both the virtual machines. We also need to enable the following ports 4789-UDP, 7946 UDP/TCP, and 2377 TCP.

For time being I already created two virtual machines in azure cloud environment.


![]({{ 'vms_list.png' | relative_url }})

Now we will try to login into the virtual machines.

![]({{ 'vm_login.png' | relative_url }})

Now we need to enable swarm mode in node 1 with the following command.
```
docker swarm init
```
The above command will enable node one as a manager and will generate a token to add a manager to this swarm.

![]({{ 'node1_swarm.png' | relative_url }})

Now we will paste this command in node two.
```
docker swarm join --token SWMTKN-1-5kd2q3hvp3kh8cynnxzaiu3dpj3rrhy9fym6wgxr0dbs9vk8dp-3x84cvrsti8fwrgkbzlkiuhwq 10.0.0.4:2377
```
![]({{ 'node2_output.png' | relative_url }})

Now let's check the active nodes by the following command.

```
docker node ls
```
![]({{ 'node_1_ls.png' | relative_url }})

Now we will check the networks in the docker by using the following command.

```
docker network ls
```
![]({{ 'docker_network.png' | relative_url }})

docker_gwbridge is the local bridge that acts as a gateway for the outside world.

Now, we will create custom overlay network with the following command.

```
 docker network create -d overlay ps-over
 ```
![]({{ 'network_create.png' | relative_url }})

In the above image, the newly created network **ps-bridge** is scoped to the swarm.

It should be available in both nodes. Let us check the same command in node two.

![]({{ 'docker_networkd2.png' | relative_url }})

So, we are not able to see correct? Any guess why we are not able to see the newly created in node two. The answer is docker has a lazy approach. It will not create a network on worker nodes immediately.

Now we will create a docker service with two replicas. Then we will attach the **ps-network** to the service.To create a service we need to use following command.

```
docker service create --name ps-svc --network ps-over --replicas 2 alpine sleep 1d
 ```

![]({{ 'docker_service.png' | relative_url }})

Let's check whether service got created or not with the following command.

```
docker service ps ps-svc
 ```

![]({{ 'docker_service_check.png' | relative_url }})

So, now lets do docker network inspect so that we can get to know VXLANId, container details.

```
docker network isnpect ps-over
 ```

![]({{ 'docker_inspect.png' | relative_url }}) 

In the above output we get to know the containers that are participated in the  **ps-over** overlay network, **vxlanid_list** and their **IPV4** ips. We can also the run same command in node-two and we will see the same result.

So let's ping node-2 ip address **192.0.0.4** from node-1.

```
ping 192.0.0.4
 ```

![]({{ 'nod1-output.png' | relative_url }})

So let's ping node-1 ip address **10.0.0.4**  from node-2.

```
ping 10.0.0.4
 ```
![]({{ 'node-2.png' | relative_url }})

By this way we can establish connectinon between two container using **Overlay Driver.**
Thanks <br>
***Kartheek Gummaluri***

<div id="disqus_thread"></div>
<script>
    /**
    *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
    *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables    */
    /*
    var disqus_config = function () {
    this.page.url = PAGE_URL;  // Replace PAGE_URL with your page's canonical URL variable
    this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };
    */
    (function() { // DON'T EDIT BELOW THIS LINE
    var d = document, s = d.createElement('script');
    s.src = 'https://https-kartheek91-github-io.disqus.com/embed.js';
    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
