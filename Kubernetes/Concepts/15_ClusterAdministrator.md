### Cluster Administrator Overview

https://kubernetes.io/docs/concepts/cluster-administration/cluster-administration-overview/

bu sayfa kesinlikle detaylı okunmalı

[Authenticating](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

[Authorization](https://kubernetes.io/docs/reference/access-authn-authz/authorization/)

[Certificates](https://kubernetes.io/docs/concepts/cluster-administration/certificates/)

### Certificates

When using client certificate authentication, you can generate certificates manually through easyrsa, openssl or cfssl.

https://kubernetes.io/docs/concepts/cluster-administration/certificates/

### Organizing resource configurations

https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/


Many applications require multiple resources to be created, such as a Deployment and a Service. Management of multiple resources can be simplified by grouping them together in the same file (separated by --- in YAML). For example:

```yml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx-svc
  labels:
    app: nginx
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

### Cluster Networking

Networking is a central part of Kubernetes, but it can be challenging to understand exactly how it is expected to work. There are 4 distinct networking problems to address:

- Highly-coupled container-to-container communications: this is solved by pods and localhost communications.
- Pod-to-Pod communications: this is the primary focus of this document.
- Pod-to-Service communications: this is covered by services.
- External-to-Service communications: this is covered by services.

### The Kubernetes network model

Every Pod gets its own IP address. This means you do not need to explicitly create links between Pods and you almost never need to deal with mapping container ports to host ports. This creates a clean, backwards-compatible model where Pods can be treated much like VMs or physical hosts from the perspectives of port allocation, naming, service discovery, load balancing, application configuration, and migration.

Kubernetes imposes the following fundamental requirements on any networking implementation (barring any intentional network segmentation policies):

- pods on a node can communicate with all pods on all nodes without NAT
- agents on a node (e.g. system daemons, kubelet) can communicate with all pods on that node
Note: For those platforms that support Pods running in the host network (e.g. Linux):

- pods in the host network of a node can communicate with all pods on all nodes without NAT


implemende edilebilcek diğer network modelleri için

https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model


### Logging

- Node Level Logging
- Cluster Level Logging
  - Using a sidecar container with the logging agent
    - Streaming sidecar container
    - Sidecar container with a logging agent


sayfa okunmalı : https://kubernetes.io/docs/concepts/cluster-administration/logging/


### Monitoring : Metrics For The Kubernetes Control Plane

https://kubernetes.io/docs/concepts/cluster-administration/monitoring/

### Configuring kubelet Garbage Collection

https://kubernetes.io/docs/concepts/cluster-administration/kubelet-garbage-collection/

### Proxies in Kubernetes

https://kubernetes.io/docs/concepts/cluster-administration/proxies/

There are several different proxies you may encounter when using Kubernetes:

1. The kubectl proxy:

   - runs on a user’s desktop or in a pod
   - proxies from a localhost address to the Kubernetes apiserver
   - client to proxy uses HTTP
   - proxy to apiserver uses HTTPS
   - locates apiserver
   - adds authentication headers
  
2. The apiserver proxy:

   - is a bastion built into the apiserver
   - connects a user outside of the cluster to cluster IPs which otherwise might not be reachable
   - runs in the apiserver processes
   - client to proxy uses HTTPS (or http if apiserver so configured)
   - proxy to target may use HTTP or HTTPS as chosen by proxy using available information
   - can be used to reach a Node, Pod, or Service
   - does load balancing when used to reach a Service

3. The kube proxy:

   - runs on each node
   - proxies UDP, TCP and SCTP
   - does not understand HTTP
   - provides load balancing
   - is just used to reach services

4. A Proxy/Load-balancer in front of apiserver(s):

   - existence and implementation varies from cluster to cluster (e.g. nginx)
   - sits between all clients and one or more apiservers
   - acts as load balancer if there are several apiservers.

5. Cloud Load Balancers on external services:

   - are provided by some cloud providers (e.g. AWS ELB, Google Cloud Load Balancer)
   - are created automatically when the Kubernetes service has type LoadBalancer
   - usually supports UDP/TCP only
   - SCTP support is up to the load balancer implementation of the cloud provider
   - implementation varies by cloud provider.

Kubernetes users will typically not need to worry about anything other than the first two types. The cluster admin will typically ensure that the latter types are setup correctly.

