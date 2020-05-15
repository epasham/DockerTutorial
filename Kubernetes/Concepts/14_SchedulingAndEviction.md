In Kubernetes, scheduling refers to making sure that Pods are matched to Nodes so that Kubelet can run them.

kube-scheduler is the default scheduler for Kubernetes and runs as part of the control plane. kube-scheduler is designed so that, if you want and need to, you can write your own scheduling component and use that instead.

kube-scheduler selects a node for the pod in a 2-step operation:

1. Filtering
2. Scoring


### Taints and Tolerations

Node affinity, is a property of Pods that attracts them to a set of nodes (either as a preference or a hard requirement). Taints are the opposite – they allow a node to repel a set of pods.

Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints.

Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes. One or more taints are applied to a node; this marks that the node should not accept any pods that do not tolerate the taints.

Taints and tolerations, podların uygunsuz node lara programlanmamasını sağlamak için birlikte çalışır. Bir node a bir veya daha fazla taints uygulanır; bu, node un taints lara tolerans göstermeyen herhangi bir pod u kabul etmemesi gerektiğini belirtir.

örnek 

train oluşturmak 

```
kubectl taint nodes node1 key=value:NoSchedule
```
train silmek
```
kubectl taint nodes node1 key:NoSchedule-
```

```yml
tolerations:
- key: "key"
  operator: "Equal"
  value: "value"
  effect: "NoSchedule"
```

```yml
tolerations:
- key: "key"
  operator: "Exists"
  effect: "NoSchedule"
```
Here’s an example of a pod that uses tolerations:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "example-key"
    operator: "Exists"
    effect: "NoSchedule"

```
diğer örnekler için sayfaya bakınız

https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

__Kullanım Senaryoları__

- Dedicated Nodes: örneğin bazı node ları sadece bazı kullancılara kullandırmak istiyorsak.

- Node with Special Hardware: 
- Taint based Evictions: A per-pod-configurable eviction behavior when there are node problems.


[Train bsed Eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-based-evictions)

[Taint Nodes by Condition](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-nodes-by-condition)


### Assigning Pods to Nodes

You can constrain a Pod to only be able to run on particular Node(s), or to prefer to run on particular nodes. There are several ways to do this, and the recommended approaches all use label selectors to make the selection.


- __nodeSelector__

1. Atach label to the node
   
```
kubectl label nodes <node-name> <label-key>=<label-value>
```

2. Add a nodeSelector field to your pod configuration

```yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
```
Then add a nodeSelector like so:
```yml
pods/pod-nginx.yaml Copy pods/pod-nginx.yaml to clipboard
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```

- __Node isolation/restriction__

The NodeRestriction admission plugin prevents kubelets from setting or modifying labels with a node-restriction.kubernetes.io/ prefix. To make use of that label prefix for node isolation:

1. Ensure you are using the Node authorizer and have enabled the NodeRestriction admission plugin.
2. Add labels under the node-restriction.kubernetes.io/ prefix to your Node objects, and use those labels in your node selectors. For example, example.com.node-restriction.kubernetes.io/fips=true or example.com.node-restriction.kubernetes.io/pci-dss=true.

- __Affinity and anti-affinity__

nodeSelector provides a very simple way to constrain pods to nodes with particular labels. The affinity/anti-affinity feature, greatly expands the types of constraints you can express.

__Node affinity__
Node affinity is conceptually similar to nodeSelector – it allows you to constrain which nodes your pod is eligible to be scheduled on, based on labels on the node.


An example of a pod that uses pod affinity:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: failure-domain.beta.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: failure-domain.beta.kubernetes.io/zone
  containers:
  - name: with-pod-affinity
    image: k8s.gcr.io/pause:2.0
```

__Inter-pod affinity and anti-affinity__

Inter-pod affinity and anti-affinity allow you to constrain which nodes your pod is eligible to be scheduled based on labels on pods that are already running on the node rather than based on labels on nodes. The rules are of the form “this pod should (or, in the case of anti-affinity, should not) run in an X if that X is already running one or more pods that meet rule Y”.

__nodeName__

nodeName is the simplest form of node selection constraint, but due to its limitations it is typically not used. nodeName is a field of PodSpec.

örnek
```yml

apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
  nodeName: kube-01

```


