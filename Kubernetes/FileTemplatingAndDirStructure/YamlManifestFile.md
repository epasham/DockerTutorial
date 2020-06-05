Bir Kubernetes objesi create etmemiz gerektiğinde yaml dosyasından bulunması gereken alanlar.

- apiVersion: Kubernetes PI versiyonu
- kind: oluşturnak istediğimiz objenin türü
- metadata: objeyi unique olarka tanımlayan kelime
- spec: hedeflediğimiz state i ifade eden bölüm

aslında bütün işin döndüğü yer spec kısmıdır diyebiliriz.  örneğin bir pod create edeceksek container ve image hakkındaki tüm bilgileri spec kısmına yazıyoruz.


Örnek Yaml

```yml

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

Kubernetes resmi sitesindeki ilgili sayfa : https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/

Declaretive Kustomizaiton file: https://kubernetes.cn/docs/tasks/manage-kubernetes-objects/kustomization/

Tüm objeler için reference sayfası: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/

Bu sayfada her türlü objenin crete, update,delete ve her türlü read işlemi için örnek Kubectl, curl ve benzeri API request ve responce örnekleri var. bu örnkerlde Yaml dosya örnekleride bulunmaktadır.

### KAYNAKLAR

- https://www.mirantis.com/blog/introduction-to-yaml-creating-a-kubernetes-deployment/
- https://azure.microsoft.com/en-in/overview/kubernetes-deployment-strategy/
- https://github.com/bitnami/charts/blob/master/_docs/authoring-kubernetes-manifests.md
- https://github.com/bitnami/charts/blob/master/_docs/authoring-kubernetes-manifests.md
