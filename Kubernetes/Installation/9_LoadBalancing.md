

#### The Kubernetes Frontend Load Balancer

Normalde kaynaklarda Kelsey'nin de etkisiyle genellikle google load balancer kurgulandığı için onun üzerinden anlatılan örneklere sıkça rastlamak mümkün. Anca biz nginx load balancer kullanacağımzıı söylemiştik. Bu nedenle şimdi bunu kurulumunu yapıyor olacağız. Daha sonra yukarıda yapmış olduğumuz çalışmaların testini yapacağız.

Load balancer için ayaraladığmız makinamızın hostname'ini nginxlb, ip'si ise 10.240.0.8 olarak belirlemiştik.


Kurulumu Ubuntu üzerinden anlayıtor olcağım ancak tek fark paket yönteicisi sonuçta diğer linux dağıtımlarından. Kurulum dışındaki ayarlar zaten hepsinde aynı şekilde.

```
$ sudo apt install -y nginx
# version check ediyoruz

$ nginx -v
# sonuç alttakine benzer olmalı. version sizde farklı olabilir tabii ki

nginx version: nginx/1.14.0 (Ubuntu)

```

Daha sonra /etc/nginx/sites-available/nginxlb.muratcabuk.com dosyasını oluşturup alttaki satıraları ekiyoruz.

- 10.240.0.2 master1
- 10.240.0.3 master2
- 10.240.0.4 master3


```
http {
    upstream backend {
      server 10.240.0.2:6443;
      server 10.240.0.3:6443;
      server 10.240.0.4:6443;

    }

    server {
      listen 6443 ssl;
      server_name nginxlb.muratcabuk.com;

      ssl on;
      ssl_certificate /etc/nginx/ssl/nginxlb.muratcabuk.com/nginxlb-muratcabuk-com.pem;
      ssl_certificate_key     /etc/nginx/ssl/nginxlb.muratcabuk.com/nginxlb-muratcabuk-com-key.pem;

      ssl_session_cache shared:SSL:20m;
      ssl_session_timeout 10m;

        location / {
              proxy_pass https://backend;

        }
     
    }
}

```


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


Ancak asıl testimizi kendi local makinamızdan nginxlb ye bağlanarak yapıyor olcağız. 

Windows makinlar için curl adresi : https://curl.haxx.se/windows/

bunun için de alttaki komutu çalıştırıyoruz.

ben host kısmına kendi hosts dosyama da kaydettiğim adresi kullandım ancak siz sunucunun public ip sini de yazabilirsiniz.


```
curl.exe --cacert ca.pem  https://nginxlb.muratcabuk.com:6443/version

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
