### Giriş ve Ön Gereksinimler

Öncelikle sistemi Azure üzerine kuracağız. Amacımız Rancher ile birlikte aynı zamanda windows swarm cluster ını da yöntebilmek. Swarm modülü Rancher app lerden uygulama olarak yüklenebiliyor.

Uygulamada ayrıca RKE Rook'u da yükleyebildiği için bunu da test etmiş olacağız. Bunun için makinalara ayrıca sdb olarak disk eklemiş olacağız. Burada oluşturduğumuz distributed diskleri aynı zamanda windows swarm altında da kullanmayı planlıyoruz.

RKE ayrıca sitio da kurabiliyor bu durumda nginx-ingress yerine istio  ingress-gateway kullancağız ve calico yüklüyor olacağız.

Öncelikle altyapıyı oluşturmak için azure-ansible klasöründeki [readme.md](azure-ansible/readme.md) dosyasını takip ediniz.

bu bize 4 adet linux makina ve 3 Adet Windows makina vermiş olacak. Windows makinalara Swarm kurulmuş olacak. Ayrıca RKE için gerekli ön gereksinimlerin hepsini de kuruyor olacak.

- ön gereksinimler : https://rancher.com/docs/rke/latest/en/os/

yukarıdaki ansible ön gereksişnimleri de kuruyor olacak.

Biz bu kurulumu yaparken RKE 1.1.9 versiyonu yayındaydı.

- Ayrıca node lar arasında ve bazı node ların dışarı açılmasında linkteki portlar açık olmalı

https://rancher.com/docs/rke/latest/en/os/#ports



Linux10 makinası bizim kurulum makinamız olacak.Aynı zamanda Load Balancer olacak. Bu makina gelen istekleri worker sunucular dağıtıyor olacak.

- [RKE kurulumnda Nginx load balancer görevi resmi makale](https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/create-nodes-lb/#2-set-up-the-load-balancer)
- [Rancher sayfasında Nginx LB kurulumu](https://rancher.com/docs/rancher/v2.x/en/installation/options/nginx/)

### Kurulum

Öncelikle 


1. **Cluster Konfigürasyon dosyası oluşturlur.**

- Dosyanın oluşturulması için bir çok ayar mevcut. Bu ayarların detyı için [şu linke](https://rancher.com/docs/rke/latest/en/config-options/) bakınız.


- ilgili ayarların en minimal ve full haliyle hazırlanmış örnekleri için [şu linke](https://rancher.com/docs/rke/latest/en/example-yamls/) bakınız.

- Cluster.yaml dosyasını oluşturmanın bir çok yolu mevcut. [Şu linkten](https://rancher.com/docs/rke/latest/en/installation/#using-rke-config) detaylar incelenebilir.

    1. rke cli kullanılarak sorulan sorulara cevap verip otomatik oluşturma seçeneği alttaki komutu kullannız.

    ```
    $ rke config --name cluster.yml
    ```
    2. boş bir dosya oluşturmak için

    ```
    $ rke config --empty --name cluster.yml
    ```
    3. Manuel oluşturlup elle doldurulabilir.

    bunu için [şu linke](https://rancher.com/docs/rke/latest/en/example-yamls/) de bakılabilir.



dosya files/rancher-cluster.yaml pathi altında oluşturldu. burada şuna dikkat etmek lazım. Normalde rke cli ~/.ssh/id_rsa path ine bakar ssh için ancak farklı bir path ise cluster conf dosyasına ssh_key_path key i ile path eklenmelidir.



2. *Daha sonra cluster oluşturulur**

```
$ rke up --config ./rancher-cluster.yml
```





### Resources

- RKE + MetalLB + Nginx-Ingress: https://www.youtube.com/watch?v=iqVt5mbvlJ0
- Ansible kullanark RKE kurulumu : https://computingforgeeks.com/install-kubernetes-production-cluster-using-rancher-rke/ 
- RKE kendi versiyonmlarında kubernets ve componentlerinin versiyonlarını eşleştiri. böylece upgrade ler daha problemsiz olur. bunu gösteren github dosyasının linki : https://github.com/rancher/kontainer-driver-metadata/blob/master/rke/k8s_rke_system_images.go
- https://enterprisecoding.com/rancher-kubernetes-engine-rke-kubernetes-kurulumu/
- https://kubernetesturkey.com/rke-k8s-kurulumu/
- https://vmknowledge.wordpress.com/2020/05/15/rke-ile-kubernetes-kurulumu/
- https://gist.github.com/htekgulds/ab3bd126390ee8beeb69f6d1c89a3c93
- https://itnext.io/setup-a-basic-kubernetes-cluster-with-ease-using-rke-a5f3cc44f26f

