#### Kubernetes Objects

Component vs Object vs Resources ??


The basic Kubernetes objects include:

- Pod
- Service
- Volume
- Namespace

Kubernetes also contains higher-level abstractions that rely on controllers to build upon the basic objects, and provide additional functionality and convenience features. These include: (aslında bunlara Resources da denilir)

- Deployment
- DaemonSet
- StatefulSet
- ReplicaSet
- Job


Kubernetes objerleri crete etmek için temel yol API ve dolayısiyle cubectl dir. hemen heme bütün objeler __state__ ve __spec__ olmak üzere alta iki objeden oluşmaktadır. 


cubectl dışında da client library ler mevcut


```
Go          github.com/kubernetes/client-go/	
Python      github.com/kubernetes-client/python/	
Java        github.com/kubernetes-client/java	
dotnet      github.com/kubernetes-client/csharp	
JavaScript  github.com/kubernetes-client/javascript	
Haskell     github.com/kubernetes-client/haskell	
```

ayrıca bide community nin oluşturdukları var [kaynak](https://kubernetes.io/docs/reference/using-api/client-libraries/#community-maintained-client-libraries)

normal şartlarda aslında status ile DSC u belirmeiş ve şuan ki durumu belirlemiş oluyoruz. Spec ilede o durumla alkalı bilgiler ivemiş oluyoruz. API referansı hakkıdna detaylı bilgi için [tıklayınız](https://kubernetes.io/docs/reference/using-api/client-libraries/#community-maintained-client-libraries).

best paracice uygulamsı olarak cli dan doğrudan API ye emeir vermektesnse yaml uzantılı konfigürasyon doyası üzerinde sisterm i ymnetmek dahmantılıklı ve hızlı bir özül olarak görülür.


```
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
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


örnek olarak
```
kubectl apply -f https://k8s.io/examples/application/deployment.yaml --record
The output is similar to this:

deployment.apps/nginx-deployment created
```


