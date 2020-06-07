etcd kurulumu master node ların hepsinde yapmamız gerekiyor. Buraya kadar aslında hiç bir kurum yapmadık kurulum esnasında lazım olacak dosyalrı oluşturduk. etcd ile birlikte bol bol kurum yapcağız.

__Peki nedir bu etcd?__

etcd bir dağınık key-value store'dur. Kubernetes cluster state'ini ve configürasyonlarını etcd'de tutmaktadır. 

[Daha etaylı bilgi almak için](https://etcd.io/docs/v3.4.0/)

__Kurulum__
```
$ wget -q --show-progress --https-only --timestamping "https://github.com/etcd-io/etcd/releases/download/v3.4.9/etcd-v3.4.9-linux-amd64.tar.gz"

$ tar -xvf etcd-v3.4.9-linux-amd64.tar.gz

$ sudo cp etcd-v3.4.9-linux-amd64/etcd* /usr/local/bin/

$ sudo mkdir -p /etc/etcd /var/lib/etcd

sudo cp /home/kubernetes/certificate_files/ca.pem /home/kubernetes/certificate_files/kubernetes-key.pem /home/kubernetes/certificate_files/kubernetes.pem /etc/etcd/
```

Daha sonra master (controller) node larda kurmuş olduğumuz etcd nin service olarak çalışmasını sağlamak amacıyla etcd.service adında bir dosyayı 3 node için de ayrı ayrı oluşturarak "/etc/systemd/system/etcd.service" path ine kopyalıyoruz. ben altta sadce master1 olan dosyasnın örneğini veriyorum acank bütün dosylara files altındaki service_files klasöründe erişebilirsiniz.

master1 için ıoluşturmuş olduğumuz bu service dosyasını inceleyecek olursak daha önce oluşturduğumuz sertifkalrında aslında sunucularda nerelerde store edilceğini de görümş oluyoruz.


```
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name master1 \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://10.240.0.2:2380 \\
  --listen-peer-urls https://10.240.0.2:2380 \\
  --listen-client-urls https://10.240.0.2:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://10.240.0.2:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster worker1=https://10.240.0.5:2380,worker2=https://10.240.0.6:2380,worker3=https://10.240.0.7:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Bu service dosyalarını da files altındaki service_files klasöründe oluşturuyoruz ve master node lardaki /home/kubernetes klasörü altıne kopyalıyoruz.

taşıdığımız bu dosyası bütün master node larda aşağıdaki komutla ilgili path' a kopyalıyoruz. 


__master1__

```
cp /home/kubernetes/service_files/master1/etcd.service /etc/systemd/system/etcd.service
```
__master2__

```
cp /home/kubernetes/service_files/master2/etcd.service /etc/systemd/system/etcd.service
```

__master3__

```
cp /home/kubernetes/service_files/master3/etcd.service /etc/systemd/system/etcd.service
```

daha sonra bütün master (controller)'larda servisi çalıştırıyoruz. Servisi enable ederken hata alırsanız büyük ihtimalle "end of line sequence" ile alakalıdır. Windows satır sonlandırma için CRLF kullanırken Linux LF kullanıe. Değiştirem yapmak için dos2unix komutunu kaullanbilirsiniz.

bu arada en start komutuna kadar olan 2 adımı tüm master (controller)'larda çalıştırıp, son adımı hepsinde arka arkaya birbirlerini beklemeden çalıştırın. Çünki etct servisi clusterdaki bütün node'lara bağlanarak ayağa kalkıyor.

```
$ sudo systemctl daemon-reload
$ sudo systemctl enable etcd
$ sudo systemctl start etcd
```

cluster ı kontrol etmek için lattaki komutu çalıştırınız

```
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
```
Sonuç şuna benzer birşey çıkacaktır.

```
19d579b62edebc85, started, master3, https://10.240.0.4:2380, https://10.240.0.4:2379, false
3c2bc8e73d7699f6, started, master2, https://10.240.0.3:2380, https://10.240.0.3:2379, false
dd7b46d4b357fcf8, started, master1, https://10.240.0.2:2380, https://10.240.0.2:2379, false
```