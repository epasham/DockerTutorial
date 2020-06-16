#### Worker Nodes

Konuya başlamadan önce şunu belitmek isityorum. Bu makale baya bi uzun olacak çünkü (bence) Kubernetes'in en karmaşık konularıdna biri network. Bu nedenle Kubernetes'in bazı pluginleri direk Linux'un kendi bileşenleri  kullandığı için çok detaya girmeden bu bileşenlere deyinmek zorunda kaldım.

Ayrıca konuyu dağıtmamak için makaleyi ikiye bölmek istemedim.

İlk olarak worker makinlarımızda swap özelliğini off yapmamız lazım. Hatta 1.8 den itibaren bildiğim kadarıyla swap açıkken sunucuyu restart ettiğimizde Kubernetes çalışmıyor. 

Bunu sebeplerini şu şekilde sıramak

- Öncelikle kubernetes swap bölümünü yönetmek için dizayn edilmedi. (tabii ki dizyn edilecek şekilde de kurgulanabilirdi ki bunu savunanlarında aşağıda linkini verdiğim bir github issue'var) 
- Kubernetes podları öngörülemez bağımlıklıklardan arındırılmalıdır. Yani swap alanının uygulamalar tarafaında nasıl handle edileceği yada performansının ne olacağı tahmin edilebilir değildir ve bu da docker felesefesine aykırıdır. Yani biz uygulamamızı paketlerken temel bazı garantilerden dolayı docker'ı kullanıyoruz ve swap alanı belirsisizlerinden dolayı bu durumu bozmaktadır.Kubernetes Podlar için 3 tip garanti sunmaktadır, bunlar  [Guaranteed, Burstable, and BestEffort](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-guaranteed).
- Ayrıca Docker mantık olarak küçük ama çok istek alan uygulamaların yönetimi üzerine kurgulanmıştır denilebilir. Yani tek başına bir podda çalışıp çok ram ve işlemci gerektiren uyulamalardan ziyade onlarca hatta belki binlerce az işlemlemci ve ram gerektiren podda çalışabilcek uygulama altyapıları Docker (dolayısyla Kubernetes) için daha mantıklıdır. işin doğası tabiiki yoğun cache (doğrudan ram değil) gerektiren uygulamar olcaktır ancak bunun için de redis, apache ignite vb in memmory store' lar kullanmak mantıklı olacaktır. 


![qos](files/qos.png)

![PodQos](files/PodQos.png)

![qos](files/qos2.jpg)

![qos](files/qos.jpg)


Bazı kullanıcılar swap mode'un açık olmasını savunmaktdırlar. En aazında bazı uyulamalar için ihtiyaç olduğunu idda edenler var.
2017 de Ekimde açılmılş olan bu issue üzerinden halen tartışmalar devam etmektedir. 

- https://github.com/kubernetes/kubernetes/issues/53533

swap alanının açık olup olmadığını görmek için

```
$ sudo swapon --show
```
Eğer ekran empty (boş) geliyora swap kapalı (disabled) demektir.

Eğer açık ise aşağıdaki gibi sonuç çıkacaktır.

```
NAME      TYPE      SIZE USED PRIO
/dev/dm-1 partition 980M   0B   -2
```

Swap alanının ayarlanabileceği diğer bir yerde fstab dosyasıdır. Bu dosya içinde de swapla ilgili birşey varsa # ile kapatmalıyız.

```
sudo vi /etc/fstab #<-- Comment out the line for swap and save it
```

devam etmeden özce az sonra kurumunu yapcağımız 3 araç için bazı bilgiler vermek istiyorum.


[conntrack-tool](https://conntrack-tools.netfilter.org/manual.html)

[Makale - Connection Tracking System](http://people.netfilter.org/pablo/docs/login.pdf)

[socat komutu hakkında](http://www.dest-unreach.org/socat/doc/README)

- __socat__ iki bağımsız kanal arasındaki veri transferi için bir relay (röle) dir, trnsferi gerçekleştirir. Bu iki kanal dosya, device (serial line, pesudo terminal), socket (UDP, TCP, IPv4, IPv6), program, file desriptor (stdin) ve benzerleri olabilir. Ençok ullanıldığı alanlardan biri de port forwarding dir.

- __conntrack__ ise "connection tracking system" için bir interface dir. yani system üzerinde çalışmamızı sağlar. peki Connection tracking sistem nedir? 

- Sistem üzerinden yapılan bazı connectionların state leri olabilir. Bu statelerin takip edilmesi ve diğer araçlar tarafından bu statelere göre işlem yapılmasını mümkün kılan siteme __connection tacking system__ denir. Bahsi geçen state'ler,

  - NEW — paket yeni bir bağlantı isyiordur, örneğin http.
  - ESTABLISHED — paket halihazırda bir cbağlantının üyesidir.
  - RELATED — paket bir bağlantının üyesi olmasına rağmen farıklı bir bağlantı daha isiyordur. öeneğin FTP 21 portundan bağlıdır ancak 20 nolu portdan transfer yapabilir..
  - INVALID — paket tracking table'daki herhangi bir bağlantıya üye değildir.

[conntract sebepli Kubernetes network problemleri](https://deploy.live/blog/kubernetes-networking-problems-due-to-the-conntrack/)


Bu arara hatırlatmakda fayda olduğunu düşünüyorum. Bu araçlar Kuberntes binaryleri değil. Linux kernel seviyesinde işlem yapmak için gerekli Yani Kubernetes'in ileride kuracağımız binary'leri bu araçlar sayesinde gerekli olan network ayarlarını yapabilmektedir.

__Peki Kuberntes bu araçlara neden ihtiyaç duyar?__

Çünkü yüzlerce hatta binlerce pod arasındaki işletişim ve bu iletişimin statelerinin yönetilmesi çok önemli bir konudur. Bu nedenle aşağıda kurumları yapılcak olan açlara  ihtiyaç bulunmaktadır.

paket kurumları sayesinde "kubectl port-forward" komutu kullanılabilir hale gelir.

3 worker da da alttaki kokurumı yapınız
```
$ apt -y install socat conntrack ipset
```

Devam etmeden önce "Container Network Interface" kavramından biraz bahsetmek istiyorum. Docker'dan farklı olarak Kubernetes kurulumunda hazır network çözümü sunmaz. Bunun için plugin'ler den birini tercih etmemzi gerekiyor.

Bu pluginler farklı network katmanlarını kullanarak podları bir biryle haberleştirmektedirler. Uzun uzadıya network anlatacak değiliz cancak konun anlaşılabilmesi için bazı terimleri hatırlamakta fayda var. Ayrıca Kubernetes ağ yönetimi için de bilmek gerekiyor. OSI katmnlarını inceleyecek olursak,

- __Layer 2 (Data Link):__ Fiziksel katmana (Layer 1) erişmek ile ilgili kuralları belirler. B ukatman verileri belirli parçalara bölerek fiziksel katmana iletir. Bu böümlere frame adı verilir.
- __Layer 3 (Network Layer):__ Bu katmanda veriler paket olarak taşınır. Farklı ağlara iletme işlemleri bu katmanda yapılır (Swich ve Route bu katmanda çalışır). 
- __Layer 4 (Transport Layer):__ Üst katman ile alt katman arasında taşıma yapar. burada veriler segment olarak taşınır


![osi](files/OSI-Model.png)

- __VXLAN:__

Özellikle bulut teknolojilerinde genişleme problemini çözmek için tasarlnamıştır. Ağın sanallaştırılması olarka tanımlayabiliriz. Peki fiziksel olarak konumlardırılan ağ sistemi nasıl sanallaştırılabilir?

Burada ethernet protokolnün tünellemesi yapılarak UDP paketlerinin içine yeni bir ethernet frame eklenmesi yoluyla sanal bir ağ sistemi fiziksel ağ üzerine kurulmuş olur.


örnek vxlan paket formatı

![vxlan](files/vxlan.png)

- __Overlay Network - P2P Network:__

Underlay network (Fiziksel network) üzerinden sanal network (Overlay network) geçirmektir. 

![peer to peer](files/peer-to-peer.jpg)
[kaynak](https://www.slideshare.net/Taimoor_Gondal/layers-and-peer-to-peer-process-dccn)


Örneğin alttaki örnekte internet üzerinden kurulmuş bir overlay network görebiliriz. Sanal Network'ün bilgileri, application layer üzerinden taşınmakatadır.

![peer to peer example](files/peer-to-peer-example.jpg)
[kaynak](https://www.slideshare.net/Taimoor_Gondal/layers-and-peer-to-peer-process-dccn)

- __Encapsulation (Kapsülleme):__

Kapsülleme hem yazılım hem de ağ teknolojilerinde sıkça kullşanılan bir kavram. Networking dünyaından bakacak olursak basitçe katmanlar arasında paketlerin sarmalanarak (kapsüllenerek) bir sonraki katmana iletilmesidir. Örneğin yukarıda belirttiğimiz sanal ağ için gerekli bilgiler bir alt katmana sarmalanarak iletilir. Yukarı doğru çıkıldıkça da bu kapsüller açılarak okunur diyebiliriz.

![kapsülleme](files/encapsulation.png)
[kaynak](https://www.cemaltaner.com.tr/2018/09/23/veri-kapsullemesi-data-encapsulation/)

aşağıdaki örneğe bakacak olursak. bir web sitesinin client'a ulaşırken yapılan kapsüllemler görülebilir.

![kapsülleme web örnek](files/web-encapsulating.png)
[kaynak](https://www.cemaltaner.com.tr/2018/09/23/veri-kapsullemesi-data-encapsulation/)

 
__Docker Default Network Model__

Docker Network Modeli hakkında detaylı bilgi için [resmi döküman sayfası](https://docs.docker.com/network/).

![The-default-networking-model-for-Docker-containers](files/The-default-networking-model-for-Docker-containers.png)
[kaynak](https://www.nakivo.com/blog/docker-vs-kubernetes/)

__Kubernetes Network Model - CNI Yokken__

Burada dikkaet dilirse aslında Docker'ın bize verdiğinden fazlası yok.

![The-networking-model-for-Kubernetes](files/The-networking-model-for-Kubernetes.png)


__Kubernetes Network Model (CNI)- Flannel Örneği__

![Flannel-can-be-used-for-building-the-overlay-network-in-Kubernetes](files/Flannel-can-be-used-for-building-the-overlay-network-in-Kubernetes.png)
[kaynak](https://www.nakivo.com/blog/docker-vs-kubernetes/)


__Ingress Network Model__

![Ingress-can-balance-the-inbound-traffic-in-Kubernetes](files/Ingress-can-balance-the-inbound-traffic-in-Kubernetes.png)


CNI, cluster içindeki podların iletişiminde sorumludur. Farklı özelliklerde pluginler mevcuttur.En çok kullanılanıları gözlemlediğim kadarıyla,

- Flannel (ücretsiz, hız odaklı, firewall yok, Layer 2 de çalışır)
- Calico (Enterprise kısmı ücretli, hız ve güvenlik (firewall) odaklı, layer 3 de çalışır, ayrıca Layer-7 kuralları Istio ile entegre policy'lerle kulladırabiliyor.)
- Wave (Enterprise kısmı ücretli, güvenlik (firewall) odaklı ama yavaş)
 
Güvenlik artıkça hız düşüyor. Test sonuçlarını için [CNI Benchmark Test Sonuçları](https://itnext.io/benchmark-results-of-kubernetes-network-plugins-cni-over-10gbit-s-network-updated-april-2019-4a9886efe9c4) sayfasını ziyaret ediniz.

Ingress Controller ise cluster dışından cluster içine gelen networkü yönetmek için kullanılır. Bunun içinde farklı seçenekler mevcut yeri geldiğinde detaylı inceleyeceğiz.

Tekrar Konumuza dönecek olursak :)

Diğer bir terim de Container Runtime Interface (CRI): kubernetes sadece Docker'ı desteklememektedir. Diğer container teknolojilerini de destekler. Bunu yapabilmesi için de CRI'a ihtiyaç vardır. CRI sayesinde farklı implemetasyonlar yapılabilir. Bazı CRI implementasyonları,

- dockershim
- cri-o
- cri-containerd
- frakti
- rktlet 

Cri-O örneği

![cri-o örneği](files/cri-o-example.jpg)

Containerd Örneği

![containerd](files/containerd-example.jpg)

Mesela Kelsey kendi kurulumunda dockerization aracı olarak containerd'yi kurmuş. Üstteki örnek containerd sistemini göstermektedir.

[Detaylı Container Runtime Anlatımı İçin Tıklayınız](https://events19.linuxfoundation.org/wp-content/uploads/2017/11/How-Container-Runtime-Matters-in-Kubernetes_-OSS-Kunal-Kushwaha.pdf)

Biz kendi örneğimizde calico'yu tercih ediyor olacağız. Flannel kadar hızlı olmasa da (çünki Flannel Layer-2 kullanıyor), Wave kadar yavaş da değil ve firewall yeteneği de var. Bu arada isterseniz Flannel kurup üzerine Calico ile güvenlik kısmı içinde kullanabilirsiniz.

Flannel ve Calico'yu beraber kullanma konusunda [bu sayfadan](https://docs.projectcalico.org/getting-started/kubernetes/flannel/) faydalanabilirsiniz.


Docker 1.11 den itibaren CRI olarak cri-containerd ye geçmiştir. Aşağıda kurumlarda containerd'yi de görebilirsiniz. Ayrıca low level container runtime olarakta "runc" yi kullanmaktadır. 

![docker containerd runc](files/containerd-docker-runc.jpg)

containerd'nin resmi sayfasından bir cümle;

"containerd is available as a daemon for Linux and Windows. It manages the complete container lifecycle of its host system, from image transfer and storage to container execution and supervision to low-level storage to network attachments and beyond."

![containerd](files/architecture.png)

![containerd](files/docker-runc-containerd.jpg)

diagramda görünen __shim__ ise container manager ile runtime arasında çalışarak entegrasyn problemlerinin yaşanmasını engeller.

containerd ile dockerd (d=daemon) arasındaki ileişim gPRC ile gerçekleşir.

__Runc__ ise OCI (Open Container Initiative) tarafıdna belirlenen specification'lara uygun şekilde container yönetimi yapan bir CLI'dır. 



![containerd](files/Containerd_Architecture_Diagram.png)


Şimdi  worker node kurulumlarına geçebiliriz.

Sırasıyla aşağıdaki bileşen ve pluginleri kuruyor olacağız.

1. Docker 19.03
2. Kubelet
3. Kube Proxy
4. Kybectl
5. Calico (dolayısıyla CNI ve CRI kurulmuş olacak)


__Docker Kurulumu__

Kurulum için [resmi Docker sayfasını](https://docs.docker.com/engine/install/ubuntu/) kullanıyor olacağım. Tek fark olarak docker versiyonunu 19.03 olarak belirtiyor olacağım.

Bütün worker node'larda bu kodları çalıştırıyoruz.

apt'ye https den paketleri yükleyebilmeleri için yetki veriyoruz.

```
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```
GPG key'i ekliyoruz

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Fingerprintin son 8 karakterini arayarak bu karakterlerle (9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88) aynı olduğunu teyid ediyoruz.

```
$ sudo apt-key fingerprint 0EBFCD88

pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

stable repository'yi ekliyoruz. Test amaçlı stable yerine örneğin nightly de kullanılabilir. Alttaki komutta önemli kısımlardann biri "lsb_release -cs" kısmı. Alttaki komutu çalıştırmadan önce kullanığınız sürümün doğru olduğunda eminolun. Örneğin ben Ubuntu 10.04 kullanıyorum bu durumda "bionic" dönmesini belkiyorum. 

```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```


Eğer alttaki komutu çalıştırıska en son stable sürün kurulur. Ancak biz bunu tercih etmiyoruz

```
 $ sudo apt-get update
 $ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Bu nedenle alttaki komutla available olan sürümleri listeleyerek Docker 19.03 kuruyor olacağız. Altta örnek listeyi verdim bizimkinde 19.03 oluyor olacak.

```
$ sudo apt-get update
$ apt-cache madison docker-ce

  docker-ce | 5:18.09.1~3-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu  xenial/stable amd64 Packages
  docker-ce | 5:18.09.0~3-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu  xenial/stable amd64 Packages
  docker-ce | 18.06.1~ce~3-0~ubuntu       | https://download.docker.com/linux/ubuntu  xenial/stable amd64 Packages
  docker-ce | 18.06.0~ce~3-0~ubuntu       | https://download.docker.com/linux/ubuntu  xenial/stable amd64 Packages
  ...
```

daha sonra specific versiyonu kuruyoruz. [VERSION_STRING] yerine 19.03 yazıyoruz. Alttaki komuta dikkat edecek olursanız containerd'nin de kurulduğunu görebilirsiniz.

```
# $ sudo apt-get install docker-ce=[VERSION_STRING] docker-ce-cli=[VERSION_STRING] containerd.io
$ sudo apt-get install docker-ce=5:19.03.11~3-0~ubuntu-bionic docker-ce-cli=5:19.03.11~3-0~ubuntu-bionic containerd.io
```
daha sonra test etmek için bütün workerlarda alttaki komutu çalıştırıyoruz.

```
$ sudo docker run hello-world
```
şu mesajı 3 worker node'da da görmüş olmalıyız.

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```
Birde containerd'nin çalışıp çalışmadığını kontrol edelim. bunun için systemctl ile bütün worket node'larda servisin çalıştığında  emin oluyoruz. Aşağıdaki komutla test edebiliriz.

```
$ sudo systemctl status containerd
```
Bu  arada Kelsey normalde bunu manuel kurduğu için sayfasında [containerd için bazı ayarlar yapıyor](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md#configure-containerd) şuan bizim bunları yapmamıza gerek yok ancak ayarların Kelsey ile uyumluluğunu test etmek isteseniz.

Containerd servis dosyası şu adreste " /lib/systemd/system/containerd.service" bulabilirsiniz. Config.toml dosyasını da şu adresten kontrol edebilirsiniz " /etc/containerd/config.toml". Service dosyasıdan gözle görülür bir fark yok ancak toml dosyasına baktığımızda ciddi farklılar olduğunu görebiliriz. En önemli fark cri plugin disabled olarak görülüyor bizdeki toml dosyasında, bunun sebebi ise aslında Docker zaten bir CRI implemetasyonuna sahip (yani kendisi zaten burada CRI uygulayıcısı). Containerd' yi de kendi ihtiyaçlarına göre zaten konfigüre ettiği için toml dosyasında bizim farklı birşey yapmamıza gerek kamamış oluyor. Ancak şunu unutmamak gerekiyor Docker yerine başka bir tool kullanıyor olsaydık bütün bu konfigürasyonu manuel yapmamız gerekebilirdi. 

runc' nin de kurulduğu nu şu şekilde kontrol edebiliriz. Runc'nin ne olduğundan yukarıda bahsetmiştik.

```
runc --version
```



__Kubernetes Binary'lerinin kurulumlarına devam edebiliriz.__

Geriye neler kaldı

- kubelet
- kube-proxy
- kubectl (zaruri değil)
- ve son olarka CNI (yani calico)

Kurumları yapmak için gerekli olan klasörleri bütün worker node'larda oluşturuyoruz.

```
$ sudo mkdir -p \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```











__Konuyla alakalı okunması gereken makaleler__
- [Resmi Kubernets Dökümanı - Kubernetes Network Model](https://kubernetes.io/docs/concepts/cluster-administration/networking/#the-kubernetes-network-model)
- [Kubernetes Community - Networking](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/network/networking.md)
- [Rancher CNI karşılaştırması](https://rancher.com/blog/2019/2019-03-21-comparing-kubernetes-cni-providers-flannel-calico-canal-and-weave/)
- [CNI Benchmark Test Sonuçları](https://itnext.io/benchmark-results-of-kubernetes-network-plugins-cni-over-10gbit-s-network-updated-april-2019-4a9886efe9c4)
- https://www.nakivo.com/blog/docker-vs-kubernetes/
- [İTÜ - Network Layer](https://bidb.itu.edu.tr/seyir-defteri/blog/2013/09/07/a%C4%9F-katman%C4%B1-(network-layer))
- [mshowto - Network Layer](https://www.mshowto.org/network-yapisinda-hostlar-arasi-iletisim.html)
- [Network Kastnaları](https://medium.com/bili%C5%9Fim-hareketi/osi-modeli-ve-7-katman-7c3bb467798c)
- [Kubernetes Networking - resimli anlatım](https://www.stackrox.com/post/2020/01/kubernetes-networking-demystified/)
- [Docker vs. containerd vs. Nabla vs. Kata vs. Firecracker and more](https://www.inovex.de/blog/containers-docker-containerd-nabla-kata-firecracker/)
- [containerd standalone kurulum ve diğer detaylar](https://medium.com/faun/docker-containerd-standalone-runtimes-heres-what-you-should-know-b834ef155426)
- [IBM CRI sayfası](https://developer.ibm.com/blogs/kube-cri-overview/?es_p=9823005)


