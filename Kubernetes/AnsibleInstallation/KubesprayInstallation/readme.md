#### Sistem Altyapı

Sistemi Azure üzerinde kullanıyor olacağız. 

Toplamda 4 sunucu kullanacağız.Master,worker ve etcd nodlarının hepsini aynı sınuculara kuruyor olacağız.  

- Load Balancer: 1 adet düşük bir bilgisayar. Nginx kurulacak. ayrıca nfs diskini de buraya kuracağız.
- Master Node: 3 adet 
- Worker Node: 3 adet
- Etcd Node: 3 adet

makinlarda swap off olmalı


ilgili ortamı Ansible Cloud Modullerini kullanarak Azure'da oluşturacağız.

gerekli ortamın kurulu için azure-ansible klasötüne bakınız.



#### örnek kurulum linkleri

bizim kurlum ayarlarımı aşağıda


- https://github.com/kubernetes-sigs/kubespray/blob/master/docs/setting-up-your-first-cluster.md
- https://github.com/kubernetes-sigs/kubespray#quick-start




#### Kurulum

python3 ve pip3 kurulu olmalı mainalarımızda

Kubespray github sayfasından 2.13.3 versiyonunu indiriyoruz.

bu versyonun zipli halini ve gerekli konfigürasyonların yapılmış halini bu projeye de ekledim. 

bende Ansible 2.9.12 versionu kurlu olduğu için kubespray klasöründeki requirements dosyasında absible versiyonunu bendeki versyonla değiştirdim.

ayrıca bende Ansible Pyuthon 3 versyonu ile birlikte kurulu komtları da buna göre çağıracağım.

1. Alttaki komutla birlikte localimizdeki gereksinimleri kuruyoruz.

```
sudo pip3 install -r requirements.txt
```

2. Kubespray klasöründe yer alan inventory altındaki sample klasörünü mycluster olarak kopyalıyoruz.

```
# Install dependencies from ``requirements.txt``
sudo pip3 install -r requirements.txt

# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster

```

3. Inventory.ini dosyası için gerekli ayarları yapıyoruz.

inventory taglari için: - https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible.md


Biz örenğimizde 3 makin akullşanıyor olacağız. master, worker ve etcd node ları aynı olacak bu nedenle ayarlamız aşağıdaki gibi olacak

public ve private ipleri ayrı ayrı girilmeli

```
[all]
node1 ansible_host=95.54.0.12  ip=10.3.0.1 etcd_member_name=etcd1
node2 ansible_host=95.54.0.13  ip=10.3.0.2 etcd_member_name=etcd2
node3 ansible_host=95.54.0.14  ip=10.3.0.3 etcd_member_name=etcd3

[kube-master]
node1
ode2
node3

[etcd]
node1
node2
node3

[kube-node]
node1
node2
node3

[calico-rr]

[k8s-cluster:children]
kube-master
kube-node
calico-rr
```

linux makinlarda swap ın off olduğundan emin olalım.


eğer python ile hazır bir inventory dosyasının oluşturulmasını istersek alttaki komutla hosts.yml dosyasının oluşmasını sağlayabiliriz.

```
# declare -a IPS=(192.168.222.111 192.168.222.101 192.168.222.102 192.168.222.103 192.168.222.104)
# CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```


4. yapmak işsteğiğimiz değişiklikler ve kumakl isteğimiz roller için alttaki dosyalkarı kullanacağız.

```
inventory/mycluster/group_vars/all/all.yml
inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml
inventory/mycluster/group_vars/k8s-cluster/addons.yml
```

bu dosyalarda yazan kelime terminolojiler için şu adrese bakabilirsiniz.

- https://kubespray.io/#/docs/ansible
- https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible.md
- https://kubespray.io/#/docs/vars
- https://github.com/kubernetes-sigs/kubespray/blob/master/docs/vars.md




inventory/mycluster/group_vars/all/all.yml dosyasında alttaki değişiklikleri yapıyoruz

load balancer için daha detaylı bilgi :

- https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ha-mode.md
- https://kubespray.io/#/docs/ha-mode


```

# bu kısım açıldı ve false yapıldı böylece intermal load balancer kapatıldı
# anladığım kadarıyla buras ınginx ingress kapatılmış oldu.
# biz bunun yerine istio kullanıyor olacağız

loadbalancer_apiserver_localhost: false


# bu kısım açıldı: aşağıdaki ayarlar gerçek makin aipleri belli olduğunda yazılacak.
# yani dışarıda 8383 ü dinleyip içeriye 6443 göndereccek demektir

## External LB example config
apiserver_loadbalancer_domain_name: "lb.muratcabuk.com"
loadbalancer_apiserver:
  address: 10.0.0.4
  port: 8383

## Local loadbalancer should use this port
## And must be set port 6443
loadbalancer_apiserver_port: 6443



# bu bölümüde açtık metric-server ın çalışması gerekli
## The read-only port for the Kubelet to serve on with no authentication/authorization. Uncomment to enable.
kube_read_only_port: 10255

```


inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml dosyaında ise aşağıdaki değişiklikleri yapıyoruz.

bu dosya kubernets componentlerinin ve kubernetes in diğer ayaralrnın yapıldıdı dosyadır. 


```
# ip aylarları: bu ayarlarıaşağıdaki gibi default aylarları ile bıraktık

kube_service_addresses: 10.233.0.0/18
kube_pods_subnet: 10.233.64.0/18

# dns: aynı bıraktık
dns_mode: coredns

# audit log for kubernetes: false tu true yaptık
kubernetes_audit: true



```



inventory/mycluster/group_vars/k8s-cluster/addons.yml


```
# Kubernetes dashboard
dashboard_enabled: true

# Helm deployment
helm_enabled: true

# Metrics Server deployment
metrics_server_enabled: true

# Nginx ingress controller deployment
ingress_nginx_enabled: true

# Cert manager deployment
cert_manager_enabled: true
cert_manager_namespace: "cert-manager"

```

addons.yml içinde ayrıca aşağıdaki gibi bir ayara  var. bu ayar ile ilşgili döküman


- https://github.com/kubernetes-sigs/kubespray/blob/master/roles/kubernetes-apps/external_provisioner/local_volume_provisioner/README.md
- https://github.com/kubernetes-retired/external-storage/tree/master/local-volume
- https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner


Bu ayar aslında her bir node içinde local diskten pod'lar için volume ayarlar. Yani disk veya folder olarak podlara ihtiyaç duymaları halinde storage sunar ancak ortk alan değildir dikkat edilmeli. Yani ilgili pod başka bir node da yada birden fazla nodda çalışıyorlasa stastik dosyalar sadecce konuldukları node da kalacaktır.

bu ayarı true olarak ayarladık.

```
# Local volume provisioner deployment

local_volume_provisioner_enabled: true
local_volume_provisioner_namespace: kube-system
local_volume_provisioner_storage_classes:
  local-storage:
    host_dir: /home/storage
#    mount_dir: /mnt/disks
    volume_mode: Filesystem
    fs_type: ext4
#   fast-disks:
#     host_dir: /mnt/fast-disks
#     mount_dir: /mnt/fast-disks
#     block_cleaner_command:
#       - "/scripts/shred.sh"
#       - "2"
#     volume_mode: Filesystem
#     fs_type: ext4

```




5. son olarak çalıştırmak için alttaki komutu kullanıyoruz


ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root cluster.yml







istio ile ingress yapmak

https://banzaicloud.com/blog/backyards-ingress/




### Kubespray ipuçları

resetleme yaparken yada tekrar ansible-playbook açlıştırıldığında inatla biryerlede takılıyorsa alltaki komutlar kullanılabilir

```
#resetle
ansible-playbook --flush-cache -i inventory/mycluster/inventory.ini reset.yml --become -u root

# ve tekrar kur
ansible-playbook --flush-cache -i inventory/mycluster/inventory.ini cluster.yml --become -u root

```




### istio kurulumu







### Kaynaklar

- https://kubernetesturkey.com/kubernetes-h-a-cluster-kurulumu/
- https://medium.com/better-programming/kubernetes-tips-ha-cluster-with-kubespray-69e5bb2fa444
- https://dzone.com/articles/kubespray-10-simple-steps-for-installing-a-product
- https://kubespray.io/#/
- https://levelup.gitconnected.com/installing-kubernetes-with-kubespray-on-nipa-cloud-a4fbeefb47ff
- https://docs.mellanox.com/pages/releaseview.action?pageId=19818992
- https://schoolofdevops.github.io/ultimate-kubernetes-bootcamp/cluster_setup_kubespray/
- https://medium.com/better-programming/kubernetes-tips-ha-cluster-with-kubespray-69e5bb2fa444




