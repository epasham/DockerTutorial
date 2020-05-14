### DNS for Services and Pods

https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/

Kubernetes DNS schedules a DNS Pod and Service on the cluster, and configures the kubelets to tell individual containers to use the DNS Service’s IP to resolve DNS names.

Assume a Service named foo in the Kubernetes namespace bar. A Pod running in namespace bar can look up this service by simply doing a DNS query for foo. A Pod running in namespace quux can look up this service by doing a DNS query for foo.bar.

daha detay için şurayı takip etmek lazım

https://github.com/kubernetes/dns/blob/master/docs/specification.md

- __Services__

“Normal” (not headless) Services are assigned a DNS A or AAAA record, depending on the IP family of the service, for a name of the form my-svc.my-namespace.svc.cluster-domain.example. This resolves to the cluster IP of the Service.
  
- __Pods__

Pod’s hostname and subdomain fields

Currently when a pod is created, its hostname is the Pod’s metadata.name value.

The Pod spec has an optional hostname field, which can be used to specify the Pod’s hostname. When specified, it takes precedence over the Pod’s name to be the hostname of the pod. For example, given a Pod with hostname set to “my-host”, the Pod will have its hostname set to “my-host”.

The Pod spec also has an optional subdomain field which can be used to specify its subdomain. For example, a Pod with hostname set to “foo”, and subdomain set to “bar”, in namespace “my-namespace”, will have the fully qualified domain name (FQDN) “foo.bar.my-namespace.svc.cluster-domain.example”.

Example:

```yml
apiVersion: v1
kind: Service
metadata:
  name: default-subdomain
spec:
  selector:
    name: busybox
  clusterIP: None
  ports:
  - name: foo # Actually, no port is needed.
    port: 1234
    targetPort: 1234
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox1
  labels:
    name: busybox
spec:
  hostname: busybox-1
  subdomain: default-subdomain
  containers:
  - image: busybox:1.28
    command:
      - sleep
      - "3600"
    name: busybox
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox2
  labels:
    name: busybox
spec:
  hostname: busybox-2
  subdomain: default-subdomain
  containers:
  - image: busybox:1.28
    command:
      - sleep
      - "3600"
    name: busybox
```


### Connecting Applications with Services
https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/

- __Exposing pods to the cluster__

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80

```

This makes it accessible from any node in your cluster. Check the nodes the Pod is running on:

```
kubectl apply -f ./run-my-nginx.yaml
kubectl get pods -l run=my-nginx -o wide

Check your pods’ IPs:

kubectl get pods -l run=my-nginx -o yaml | grep podIP
    podIP: 10.244.3.4
    podIP: 10.244.2.5

```

- __Creating a Service__
So we have pods running nginx in a flat, cluster wide, address space. In theory, you could talk to these pods directly, but what happens when a node dies? The pods die with it, and the Deployment will create new ones, with different IPs. This is the problem a Service solves.

```sell
kubectl expose deployment/my-nginx

service/my-nginx exposed
```


This is equivalent to 

kubectl apply -f the following yaml:

```yml
service/networking/nginx-svc.yaml Copy service/networking/nginx-svc.yaml to clipboard
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
```

This specification will create a Service which targets TCP port 80 on any Pod with the run: my-nginx label, and expose it on an abstracted Service port (targetPort: is the port the container accepts traffic on, port: is the abstracted Service port, which can be any port other pods use to access the Service). View Service API object to see the list of supported fields in service definition. Check your Service:

```
kubectl get svc my-nginx

NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
my-nginx   ClusterIP   10.0.162.149   <none>        80/TCP    21s
```


Check the endpoints, and note that the IPs are the same as the Pods created in the first step:

```
kubectl describe svc my-nginx


Name:                my-nginx
Namespace:           default
Labels:              run=my-nginx
Annotations:         <none>
Selector:            run=my-nginx
Type:                ClusterIP
IP:                  10.0.162.149
Port:                <unset> 80/TCP
Endpoints:           10.244.2.5:80,10.244.3.4:80
Session Affinity:    None
Events:              <none>
```

```
kubectl get ep my-nginx


NAME       ENDPOINTS                     AGE
my-nginx   10.244.2.5:80,10.244.3.4:80   1m


You should now be able to curl the nginx Service on <CLUSTER-IP>:<PORT> from any node in your cluster. Note that the Service IP is completely virtual, it never hits the wire. If you’re curious about how this works you can read more about the service proxy

```

- __Accessing the Service__

```
kubectl exec my-nginx-3800858182-jr4a2 -- printenv | grep SERVICE

KUBERNETES_SERVICE_HOST=10.0.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
```

- __DNS__
Kubernetes offers a DNS cluster addon Service that automatically assigns dns names to other Services. You can check if it’s running on your cluster:

```
kubectl get services kube-dns --namespace=kube-system

NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns   ClusterIP   10.0.0.10    <none>        53/UDP,53/TCP   8m
```




