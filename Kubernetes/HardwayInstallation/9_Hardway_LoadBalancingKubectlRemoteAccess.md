

#### The Kubernetes Frontend Load Balancer

Normalde kaynaklarda Kelsey'nin de etkisiyle genellikle google load balancer kurgulandığı için onun üzerinden anlatılan örneklere sıkça rastlamak mümkün. Anca biz nginx load balancer kullanacağımzıı söylemiştik. Bu nedenle şimdi bunu kurulumunu yapıyor olacağız. Daha sonra yukarıda yapmış olduğumuz çalışmaların testini yapacağız.

Load balancer için ayaraladığmız makinamızın hostname'ini nginxlb, ip'si ise 10.240.0.8 olarak belirlemiştik.


Kurulumu Ubuntu üzerinden anlayıtor olcağım ancak tek fark paket yönteicisi sonuçta diğer linux dağıtımlarından. Kurulum dışındaki ayarlar zaten hepsinde aynı şekilde.


https://www.ovh.com/blog/getting-external-traffic-into-kubernetes-clusterip-nodeport-loadbalancer-and-ingress/

```
$ sudo apt install -y nginx
# version check ediyoruz

$ nginx -v
# sonuç alttakine benzer olmalı. version sizde farklı olabilir tabii ki

nginx version: nginx/1.14.0 (Ubuntu)

```

Daha sonra /etc/nginx/nginx.conf dosyasını açıp alttaki satırları ekliyoruz.

```
stream {


    upstream backend {
        server master1:6443;
        server master2:6443;
        server master3:6443;
   }

    server {
        listen 6443;
        listen 443;
        proxy_pass backend;

    }

}

```

burada dikkat etmemiz gereken en önemli konu, api sertifikasını tanımlarken kullanılabilcek hostname'lerden birini load balancer ımıza tanıtmamız gerekiyor. 

kendi load balancer ım da kubernetes.default u tanımladım ve local bilgisayartımda da host dosyasına load balancer'ın public ip'sine bu domaini bağladım.

- kubernetes servisin dns ip si: 10.32.0.1
- master1: 10.240.0.2
- master2: 10.240.0.3
- master3: 10.240.0.4
- localhost: 127.0.0.1
- nginxlb: 10.240.0.8
- nginxlb.muratcabuk.com (kendi domaininizi yazabilirsiniz, load balancer/proxy domaini)
- kubernetes
- kubernetes.default
- kubernetes.default.svc
- kubernetes.default.svc.cluster
- kubernetes.svc.cluster.local




Test etmek için nginxlb makinasında alttaki komutu çalıştırıyoruz. Sonuç olarak kube api server bize alttaki gibi biz json mesaj dönecektir. 

```
curl --cacert /home/kubernetes/certificate_files/ca.pem  https://127.0.0.1:6443/version

# Sonuç olarak


{
  "major": "1",
  "minor": "18",
  "gitVersion": "v1.18.0",
  "gitCommit": "9e991415386e4cf155a24b1da15becaa390438d8",
  "gitTreeState": "clean",
  "buildDate": "2020-03-25T14:50:46Z",
  "goVersion": "go1.13.8",
  "compiler": "gc",
  "platform": "linux/amd64"
}

```

dikkat ederseniz 127.0.0.1 ile api yi çağırabildik çünki api sertifikasında 127.0.0.1 ip'si tanımlı.

Ancak asıl testimizi kendi local makinamızdan nginxlb ye bağlanarak yapıyor olcağız. 

Windows makinlar için curl adresi : https://curl.haxx.se/windows/

bunun için de alttaki komutu çalıştırıyoruz.

ben host kısmına kendi hosts dosyama da kaydettiğim adresi kullandım ancak siz sunucunun public ip sini de yazabilirsiniz.

untrasted hatası almanız durumunda --insecure parametresini de ekleyiniz


```
curl.exe --cacert ca.pem  https://kubernetes.default:6443/version

# ip version

curl.exe --cacert ca.pem  https://165.227.247.99:6443/version

# SONUÇ

{
  "major": "1",
  "minor": "18",
  "gitVersion": "v1.18.0",
  "gitCommit": "9e991415386e4cf155a24b1da15becaa390438d8",
  "gitTreeState": "clean",
  "buildDate": "2020-03-25T14:50:46Z",
  "goVersion": "go1.13.8",
  "compiler": "gc",
  "platform": "linux/amd64"
}

```


Şuan api'yi dışarıdan erişime load balancer/proxy üzerinden açmış olduk.


Local bilgisayarımızdab kubectl ile apiye komut gönderebilmek için alttaki ayarları yapıyoruz.

Bunun için sertifikları C dizini altındaki kubernetes klasörüne kopyaladıktan sonra alttaki komutları admin.kubeconfig dosyasındaki clustername ve user parametre değerlerine uygun olarak çalıştırıyoruz.



```
kubectl.exe config set-cluster kubernetes-the-hard-way --certificate-authority=c:\kubernetes\ca.pem --embed-certs=true --server=https://kubernetes.default:6443

kubectl.exe config set-credentials admin --client-certificate=admin.pem --client-key=c:\kubernetes\admin-key.pem 

kubectl.exe config set-context kubernetes-the-hard-way --cluster=kubernetes-the-hard-way --user=admin

kubectl.exe config use-context kubernetes-the-hard-way
```

test etmek için 


```
kubectl.exe get componentstatuses

# SONUÇ

controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd1               Healthy   {"health":"true"}
etcd2               Healthy   {"health":"true"}
etcd3               Healthy   {"health":"true"}
```
