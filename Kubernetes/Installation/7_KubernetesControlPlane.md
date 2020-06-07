Bu adımdan itibaren artık Kubernetes kurumuna da başlıyor olacağız. Amacımız sadece kurulum yapmak tabii ki ancak, kurulumunu yaptığımız Kubernetes bileşeni hakkında ufak tefek bilgiler vermenin konunun daha kalıcı olacağı kanısındayım. Ayrıca neyi ne için yaptığımızın anlaşılmasına da yardımıcı olacağını düşünüyorum.

Konuya ufak bir giriş yaptıkran sınra Control Plane kurulumununa aşağıda devam ediyor olacağız.

Resmi dökümanlardaki kitabi tanımına bakacak olursak. Kontrol Panel (Control Plane), sistemdeki tüm [Kubernetes nesnelerinin](https://kubernetes.io/docs/concepts/overview/components/) kaydını tutar ve bu nesnelerin durumunu yönetmek için sürekli kontrol döngüleri çalıştırır. Herhangi bir zamanda, Kontrol Paneli'nin kontrol döngüleri kümedeki değişikliklere yanıt verir ve sistemdeki tüm nesnelerin gerçek durumunu verdiğiniz istenen durumla eşleştirmek için çalışır.


- [Control Plane](https://kubernetes.io/docs/concepts/#kubernetes-control-plane)
- [Control Plane Communication](https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/)



![control plane](files/components-of-kubernetes.png)
 [kaynak](https://kubernetes.io/docs/concepts/overview/components/)


__Kubernetes Nesneleri (Objects)__
- Pods
- Namespaces
- ReplicationController (Manages Pods)
- DeploymentController (Manages Pods)
- StatefulSets
- DaemonSets
- Services
- ConfigMaps
- Volumes

Konumuz olmadığı için nesnelerin yönetimi ile ilgili başlıklara değinmiyoruz ancak mera edenler için aşağıda resmi Kubernetes sayfasından bazı linkleri paylaşıyorum. 

- [Declarative Konfigürasyon dosyaları ile yönetmek](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/)
- [Kustomize ile Yönetmek](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Imperative Komutlarla Yönetmek](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/imperative-command/)
- [Imprerative Konfigürasyon Dosyaları ile Yöntemek](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/imperative-config/)


__Kubernetes Resources__

Resource kelimesinin genelde bilinen anlamı kaynaktır. Ancak diğer anlamlarına bakacak olursak uğraş, beceri, vasıta vb anlamlara da gelmektedir. Zannediyorum burada Kubernetes yazılımcıları bu ikincil anlmaları da kapsayacak şekilde kullanmak istemişler resource kelimesini. Resource, objects ifadesini de kapsaycak şekilde tanımlaanmıştır ancak daha fazlasını da içerir. Bunu iyi bilmek lazım çünki Kubernetes API referanslarınmı ve versiyonlarını dah iyi kavramanıza yardımcı olacaktır. 

Şu komutla resource'ların listesini alabiliriz.

```
kubectl api-resources -o wide 
```

Bazı Resource tiplerine bakacak olursak.

- DaemonSet
- Deployment
- ReplicaSet
- StatefulSet
- Job
- CronJob
- Pod
- Node
- ReplicationController
- Secret
- Event
- Ingress
- Role
- Ingress
- RoleBinding
- SelfSubjectAccessReview
- PersistentVolume
- vb

Peki object ile resource arasındaki fark nedir? aslında resource'ların da olmasının temel amacı temelde object oluşturmaktır. Temelde üzerinde değişiklik yaptığımız, nasıl çalışacağına, ne kadar olacağına vb karar verdiğimiz aktif olarak ortaya içerik koyanlar object'ler yani nesnelerdir. Bir ayırım, örneğin pod'un zaten kendisi tek başına bir üründür ve pod (extreme örnekleri varsaymazsak) bir başka ürün ortaya çıkartmak için oluşturulmazlar.

Daha önce okumuş olduğum kaynaklardan aklımda kalan bir örnekle açıklamaya çalışacağım. Örneğin bir restoranda tek başına et bir ürün olabiir. Yani et istiyorum derseniz belki garson et yemeği de getirebilir. Ancak menüye baktığınızda sadece et yazan bir yemek göremezsiniz. Sizin önünüze eninde sonunda bir et yemeği gelir fakat menude ana konusu et olan farklı yapılış şekilleriyle, bahratlarıyla ve farklı isimlerle bir çok et yemeği vardır. 

Bu örnekte et kavramını pod, örneğin et kavurma, et şiş, et haşlama gibi etin farklı yapılışlarını da resource' a benzetebiliriz.

StatefulSet veya ReplicaSet de bize eninde sonunda pod(lar) olulturur ancak ortaya öıkan pod'ların oluştulma süreci ve davranışları farklı farklı olacaktır. Ve buradanda anlaşılağı üzere biz ReplicaSet olşuştururuz (create) ancak asıl amacımız aslında pod oluşturmaktır.

Konumuz kurulum olduğu içinkonuyu burada noktalıyoruz. Ancak Kuberntes'i kullanmayı da öğrenmesini yolu bu kavramların altını pratikte de doldurmakdan geçiyor.

__Kontrol Panel Bileşenleri (Control Plane Components)__
- kube-api server
- etcd
- kube-scheduler
- kube-controller-manager
- cloud-controller-manager

__Worker Node Components__
- kubelet
- kube-proxy
- Container Runtime

__Birde sistemde olması gereken temel bazı Addon'lar var__ 
- DNS
- Web UI (Dashboard)
- Cluster-level Logging


![control plane](files/controlplane.jpg)
[kaynak](https://www.redhat.com/en/topics/containers/kubernetes-architecture)

#### Kubernetes Control Plane

İlk makalede belirttiğimiz üzere Kubernetes Komponentlerinin 1.18 veriyonunu yüklüyor olacağız.

Aksi belirtilmedikçe aşağıdaki komutlar ve dolayısıyle kurulumlar bütün Master (controller) node'larda yapılcaktır. Bu nedenle Linux için tmux, Winsdows için Cmder kullanmanızı tavsiye ederim.

öncelikle Kubernetes konfigüeasyon klasörünü oluşturuyoruz.

```
$ sudo mkdir -p /etc/kubernetes/config
```

Daha sonra gerekli binary'leri download ediyoruz.

```
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl"
```
[Kaynak](https://kubernetes.io/docs/setup/release/#server-binaries)

daha sonra kurulumu yapıyoruz

```
$ chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
$ sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
```
![control plane](files/components-of-kubernetes.png)
 [kaynak](https://kubernetes.io/docs/concepts/overview/components/)

 Daha sonra aşağıdaki komponenetlerin kongigrasyonunu yapıyoruz

 - Kubernetes API Server
 - Controller Manager
 - Kubernetes Scheduler


__Kubernetes API Server Konfigürasyonu__

__Controller Manager Konfigürasyonu__

__Kubernetes Scheduler Konfigürasyonu__

