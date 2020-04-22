şua çıklamaya dikkat et

Overlay network limitations

You should create overlay networks with /24 blocks (the default), which limits you to 256 IP addresses, when you create networks using the default VIP-based endpoint-mode. This recommendation addresses limitations with swarm mode. If you need more than 256 IP addresses, do not increase the IP block size. You can either use dnsrr endpoint mode with an external load balancer, or use multiple smaller overlay networks. See Configure service discovery for more information about different endpoint modes.

https://docs.docker.com/engine/reference/commandline/network_create/#overlay-network-limitations

https://docs.docker.com/engine/reference/run/#network-settings


