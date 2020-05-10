https://docs.docker.com/engine/swarm/ingress/

Docker Engine swarm mode makes it easy to publish ports for services to make them available to resources outside the swarm. All nodes participate in an ingress routing mesh. The routing mesh enables each node in the swarm to accept connections on published ports for any service running in the swarm, even if there’s no task running on the node. The routing mesh routes all incoming requests to published ports on available nodes to an active container.

![ingreess](files/ingress-lb.png)

To use the ingress network in the swarm, you need to have the following ports open between the swarm nodes before you enable swarm mode:

- Port 7946 TCP/UDP for container network discovery.
- Port 4789 UDP for the container ingress network.


You must also open the published port between the swarm nodes and any external resources, such as an external load balancer, that require access to the port.

You can also [bypass the routing mesh](https://docs.docker.com/engine/swarm/ingress/#bypass-the-routing-mesh) for a given service.

To bypass the routing mesh, you must use the long --publish service and set mode to host. If you omit the mode key or set it to ingress, the routing mesh is used. The following command creates a global service using host mode and bypassing the routing mesh.

```
$ docker service create --name dns-cache \
  --publish published=53,target=53,protocol=udp,mode=host \
  --mode global \
  dns-cache

  ```

