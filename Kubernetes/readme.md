Dış Kaynaklar

1. References SAyfası

https://kubernetes.io/docs/reference/


bu sayfada tüm CLI ve API  referanslarına erişmek münmkün.

Ayrıca API ye arişim ve detaylı use case kullanımlarıyla anlatılıyor.

2. Tasks Sayfası

bu sayfada gerçek kullanımda karşılaşacağımız bir çok uzer case ile ilgili baştan sona uygulamalar mevcut.

Kurulum. konfigurasyon, Job yönetimi, güvenlik, monitoring, loglama, networking vb bir çok konu başlığı mevcut

3. Getting Started

öcellikle Best Practice ler sayfası çok faydalı

https://kubernetes.io/docs/setup/best-practices/multiple-zones/


4. Kapsamlı Kubernetes Sayfası

https://ansilh.com/

5. Kore Dilinde Şekillerle Anlatılmış (Çok İyi)

- https://kubetm.github.io/practice/

- https://kubetm.github.io/plan/


İç Kaynaklar


- [Kubernetes Concept](Concept/readme.md)
- [Kubeadm Installation](KubeadmInstallation/readme.md)
- [Ansible Installation](AnsibleInstallation/readme.md)
 - [Kubespray Installation](AnsibleInstallation/KubesprayInstallation/readme.md)
 - [Azure Infra Installation with Ansible](AnsibleInstallation/KubesprayInstallation/azure-ansible/readme.md)
 - [ETCD](AnsibleInstallation/KubesprayInstallation/etcd/readme.md)
 - [Istio](AnsibleInstallation/KubesprayInstallation/istio/readme.md)
   - [MetalLB](AnsibleInstallation/KubesprayInstallation/istio/metallb.md)
   - [Calico](AnsibleInstallation/KubesprayInstallation/istio/calico.md)
  - [Persistant Volume](AnsibleInstallation/KubesprayInstallation/PersistantVolume/readme.md)
- [Hardway Installation](HardwayInstallation/readme.md)
- [Hardway Installation 2](HardwayInstallation2/readme.md)
- [File Templating and Directory Structure](FileTemplatingAndDirStructure/readme.md)
- [Helm](Helm/readme.md)
- [Nginx-Ingress](Nginx-Ingress/readme.md)
- [Istio](Istio/readme.md)
- [Persistant Volume](PersistantVolume/readme.md)
  - [Local PErsistant Volume](LocalPersistantVolume/readme.md)
  - [Minio Persistant Volume](MinioPersistantVolume/readme.md)
  - [NFS Persistant Volume](NFSPersistantVolume/readme.md)
  - [DynamicNFSPersistantVolume](DynamicNFSPersistantVolume/readme.md)
  - [Rook](Rook/readme.md)
- [Etcd](Etcd/readme.md)
- [MetalLB](MetalLb/readme.md)
- [RKE](RKE/readme.md)
- [Rancher](Rancher/readme.md)
- [KubeOne](KubeOne/readme.md)
- [Cert-Manager](Cert-Manager/readme.md)
- [Troubleshooting](Troubleshooting/readme.md)
- [References](References/readme.md)
- [Kubernetes Examples](KubernetesExamples/readme.md)
- [Windows Presentation](WindowsPresentation/readme.md)
- [Linux Presentation](LinuxPresentation/readme.md)























Kubernetes' i incelerken iki bölüme ayıracağız 

1. Kubernetes Yönetici
2. Kubernetes Yazlımcı




Kubernetes ağ yapısı ile ilgili bu seriye kesin bak

- https://oguzhaninan.gitlab.io/Kubernetes-CNI-karsilastirmasi-Flannel-Calico-Canal-ve-Weave/ (kesin bak)
- https://oguzhaninan.gitlab.io/Kubernetes-Service-Mesh-Araclari/ (kesin bak)
- https://oguzhaninan.gitlab.io/Kubernetes-Ingress-Controllers/ (jesin bak)
- https://oguzhaninan.gitlab.io/Kubernetes-Flannel-Ag-Yapisi/ (kesinlikle detaylı bir şekilde oku)


- http://www.umitdemirtas.com/kubernetes/
- https://docs.docker.com/get-started/kube-deploy/
- https://medium.com/codable/kubernetes-d090867428ca
- https://www.youtube.com/watch?v=5BqHWjz4LXE (güzel amlatım)


#### service mesh

- service mesh üzerinde queue araştırılmalı

service mesh üzerinde event driven kullanım

- https://www.infoq.com/articles/service-mesh-event-driven-messaging/
- https://glasnostic.com/blog/comparing-service-meshes-linkerd-vs-istio
- https://www.weave.works/blog/introduction-to-service-meshes-on-kubernetes-and-progressive-delivery


çalışma ve test için: https://www.katacoda.com/

