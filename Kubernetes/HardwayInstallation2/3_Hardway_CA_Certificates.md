#### kubectl in client (windows) a kurulması

diğer işletim sistemleri için aşağıdaki linki kullanbilşrsiniz

https://kubernetes.io/docs/tasks/tools/install-kubectl/

Windows kurulumu için alttaki linki takip ediyor olacağız

https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows

bu sayfada bir çok kurulum seçeneği mevcut 

- direk exe yi indirmek . https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/windows/amd64/kubectl.exe
- Chocolatey or Scoop
- yada curl ile kurulum gibi

artık hangisi kolayınıza geliyorsa.

ben direk olarka download ettim. Unutmayın v1.18.0 indiriyoruz.

ilgili exe yi bir klasöre koyarak environmet a eklerseniz kubectl i direk command promp dan çağırabilirsiniz.

komut satırında kubectl version yazdığımızda alttaki satırları görmemiz lazım

```
kubectl version

Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"windows/amd64"} 
```

#### sertifika pki ların kurulması


komutları çalıştırırken files klasörü altındaki certificate_configs klasörünü work directory olarak konumlandırınız.


![tsl](files/kubernetes-control-plane.png)

oklarla görünen her bağlantı için aslında bir sertifikaya ihtiyacımız olacak.

[Gerekli Olan Sertifikalar Hakkında Checklist](files/kubernetes-certs-checker.xlsx)

aşağıdaki sertifikaları üretiyor olacağız.


1. admin user
2. kubelet
3. kube-controller-manager
4. kube-proxy
5. kube-scheduler
6. kube-api

Kubernetes resm sertifika sayfası

https://kubernetes.io/docs/concepts/cluster-administration/certificates/

genelde kaynaklarda cfssl kullanılmış. bizde cfssl ile bütün sertifikalarımızı üretiyr olacağız. burada şuna diakkat etmek gerekiyor ilgili sertifikaları oluşturuken kullanacağımız bütün konfigürayon dosyaları files klasöründe certificate_configs diye bir klaösr var bu klasörde cfssl tarafından kullanılacak bütün config dosyaları mevcut.

konfigürasyon dosyları incelenecek olursa CN, O yazan bölümlerde örneğin system:kube-controller-manager gibi bilgiler yazmaktadır. Bunlar özellikle bu şekilde yazılmıştır bu nedenle aynen bu şekilde kullanılmalı. ancak master ve worker nod lar için yazılanlar kendi oramınız için farklılık gösterebilir buralar değiştirlebilir bu nedenle.

- [cfssl detaylı anlatım için](https://github.com/cloudflare/cfssl) 

windows a kurmak için alttaki linkten listedekileri indiriyoruz.


- cfssl_1.4.1_windows_amd64.exe
- cfssljson_1.4.1_windows_amd64.exe

https://github.com/cloudflare/cfssl/releases


büyük ölçüde cfssl_1.4.1_windows_amd64.exe ile devam ediyor olcağız.

sertifikaları windows client makinamızda create edeceğimiz için exe ye vesion parametresi verdiğimizde 1.4.1 i görmemiz lazım
```
cfssl_1.4.1_windows_amd64.exe version

Version: 1.4.1
Runtime: go1.12.12

```

sertifika oluşturuken bazı yerlerde aşağıdaki gibi bir hata alınabilir. bu public e açılacak sertifikalrda host belirtilmezse güvenlik açığına sebebiyet verebileceğine dair bir hata. biz private alanda kullanacağımız için problem değil.

```
[WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for                      websites. For more information see the Baseline Requirements for the Issuance and Management                            of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);                            specifically, section 10.2.3 ("Information Requirements").
```




__1. Certificate Authoirty (CA)__

bu sertifika tek olcak. kendi kendini imzalayak (yani self signed). bu sertifika ile diğer sertifikaları imzalıyor olacağız. intermediate sertifika oluşturmaya gerek yok.

```
cfssl_1.4.1_windows_amd64.exe gencert -initca ca-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare ca
```

sonuç olarka 2 adet dosya oluştu.
- ca-key.pem
- ca.pem

__2. Admin User Client Certificate__



```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare admin
```

sonuç olarak 2 adet dosya oluştu
- admin-key.pem
- admin.pem

__3. Kubelet Client Certificates__

bizim 3 adet worker ımız var. normalde bunlar için örneklerde bir for dögüsüyle txt dosyasından okunarak csr dosyaları create dilir ve daha sonra ikinci bir döngü ile de sertifikalar create edilir. acnk bir karmaşık olmaması için csr dosyalarını elimizle oluşturduk.

3 adet worker için tek tek 3 adet komut çalıştıracağız. Linux'de shell ve Windows'da Powershell ile döngü yardımıyla da  oluşturulabilir Ancak burada yazdığımız komutları mümkün oldukça sadece tutmaya çalılşıyoruz. 


- __worker1 için kubelet client sertifika oluşturulması__

Kelsey'nin de yaptığı gibi bizde dış ip adreslerimizi  de ekliyoruz hostname parametresine.


```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=worker1,10.240.0.5,164.90.180.233  -profile=kubernetes worker1-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare worker1
```
sonunda 2 adet dosya oluştu

  1. worker1-key.pem
  2. worker1.pem

- __worker2 için kubelet client sertifika oluşturulması__

```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=worker2,10.240.0.6,142.93.163.5  -profile=kubernetes worker2-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare worker2
```
sonunda 2 adet dosya oluştu

  1. worker2-key.pem
  2. worker2.pem

- __worker3 için kubelet client sertifika oluşturulması__

```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=worker3,10.240.0.7,64.225.109.190  -profile=kubernetes worker3-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare worker3
```
sonunda 2 adet dosya oluştu

  1. worker3-key.pem
  2. worker3.pem

__4. Controller Manager Client Certificate__

burada şuna dikkat etmek lazım; az önce kubelet şiçin 3 adet ayrı ayrı sertifika create ettik. sebei ise kubelet klerin her worker için ayrı ayrı çalışıyor olması.

Ancak controller-manager bir cluster  (HA) bile olsa sonuçtatek bir servis gibi çalışıyor bu ndenle biz servic için tek bir sertifika üretiyor olcağız.

```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes   kube-controller-manager-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare kube-controller-manager
```
sonuçta 2 dosya oluştu
  1. kube-controller-manager-key.pem
  2. kube-controller-manager.pem

__5. Kube Proxy Client Certificate__

kube-proxy de aynı contoller gibi bir service, bu nedenle cluster olarak bile kurulsa aslında tek bir service olark çalışacağından biz de tek sertifika oluşturuyoruz.

```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare kube-proxy
```
sonuçta 2 dosya oluştu

  1. kube-proxy-key.pem
  2. kube-proxy.pem


__6. Scheduler Client Certificate__

kube-scheduler de aynı contoller ve proxy gibi bir service, bu nedenle cluster olarak bile kurulsa aslında tek bir service olark çalışacağından biz de tek sertifika oluşturuyoruz.

```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes   kube-scheduler-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare kube-scheduler
```
sonuçta 2 dosya oluştu

 1. kube-scheduler-key.pem 
 2. kube-scheduler.pem


__7. Kubernetes API Server Certificate__

![tsl](files/kubernetes-control-plane.png)

resimde master 1 tane bizde ise 3 tane. bu durmda aslında hem API server hemde controller 3 tane olmuş oldu. ayrıca bu 3 master için bir load balancer kurmuştuk (kubelb), bu load balancer için kullanacağımız domain adını da eklememiz gerekiyor.

bu sertifikayı oluşturuken bu servisi (API servisi) kullancak bütün bu altyapıdaki node ların host bilgilerine ihtiyacımız olacak. yani servisin aslında yayınlandığı host bilgilerine

yani

- kubernetes servisin dns ip si: 10.32.0.1
- master1: 10.240.0.2
- master2: 10.240.0.3
- master3: 10.240.0.4
- localhost: 127.0.0.1
- kubelb: 10.240.0.8
- kubelb.muratcabuk.com: 164.90.166.195 (kendi domaininizi yazabilirsiniz, load balancer/proxy domaini)
- kubernetes
- kubernetes.default
- kubernetes.default.svc
- kubernetes.default.svc.cluster
- kubernetes.svc.cluster.local

bu ip ve adresler aynı zamanda bu sertifikayı bu adresler ile kullanbilceğimiz anlamına geliyor. bu durumda load balancer ımıza kubernetes.default adını verip (yani hosts dosyasına ekleyip) api mizi bu isimle çağırabiliriz.



The Kubernetes API server is automatically assigned the kubernetes internal dns name, which will be linked to the first IP address (10.32.0.1) from the address range (10.32.0.0/24) reserved for internal cluster services during the control plane bootstrapping lab.

bu ip networkayarlarını yaprken bahsettiğimiz service lerin kullanacağı ip bloğunun ilk ip. Bunu ilk ip olarak yazmış olmamız önemli çünki bu ilk ip adres kubernets servisinin dns ip si olarka ataıyor olacak.

```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=10.32.0.1,master1,10.240.0.2,master2,10.240.0.3,master3,10.240.0.4,localhost,127.0.0.1,kubelb,10.240.0.8,kubelb.muratcabuk.com,164.90.166.195,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local -profile=kubernetes kubernetes-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare kubernetes
```

anlaşılması adına openssl deki ayn sertifikayı oluşturulurken kullanılan kod örneği

dikkat edilirse DNS.1=kubernetes ve IP.1=10.32.0.1 buralar DNS kaydını gösteriyor

```
cat > openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.32.0.1
IP.2 = 192.168.5.11
IP.3 = 192.168.5.12
IP.4 = 192.168.5.30
IP.5 = 127.0.0.1
EOF
```



kodu çalıştırdığımızda 2 dosya oluşmuş oldu

  1. kubernetes-key.pem 
  2. kubernetes.pem



__8. Service Account Key Pair__

Neden ihtiyaç duyduğumuzla alakalı okunabilir.
https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/

```
cfssl_1.4.1_windows_amd64.exe gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes service-account-csr.json | cfssljson_1.4.1_windows_amd64.exe -bare service-account
```

sonuç olarak 2 dosya oluştu

  1. service-account-key.pem
  2. service-account.pem

tam bu noktada devem etmeden önce şuna değinmek istiyorum. 9. madde zorunlu değil. Aslında elimizde bütün sertifikalr var ancak bazen hızlı olma adına bazen test amaçlı yada eğitim amaçlı sertifikaları bu kadar detaylı hazırlamak istemeyebiliriz. bu dumda tek bir sertifika da işimizi görecektir. 9. madde bu konuya değinmketedir. Eğer ilgilenmiyorsanız 10. maddeye geçebiliriz.

__9. Tek Sertifika Üretme Seçeneği__

- https://kubernetes.io/docs/concepts/cluster-administration/certificates/#certificates-api
- https://github.com/Praqma/LearnKubernetes/blob/master/kamran/Kubernetes-The-Hard-Way-on-BareMetal.md

biz produciton ortamındaymışız gibi bütün sertifikalrı tek tek oluşturudk. aslında güvenlik durumu olmayan yerlerde tek sertifika oluşturulabilirç. sadece sertifika ayarlaın adikkat etmek lazım.

örneği linux üzerinde cfssl ile şu şekilde

```
# 1. Create a Certificate Authority

echo '{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}' > ca-config.json

# 2. Generate CA certificate and CA private key

echo '{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NO",
      "L": "Oslo",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oslo"
    }
  ]
}' > ca-csr.json

# 3. Now, generate CA certificate and it's private key

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# This should give you the following files:

#ca.pem
#ca-key.pem
#ca.csr

# 4. You can verify that you have a certificate, by using the command below:

openssl x509 -in ca.pem -text -noout

# 5. Generate the single Kubernetes TLS certificate:

export KUBERNETES_PUBLIC_IP_ADDRESS='10.240.0.20' # dikkat kendi ip niz olacak

# 5.1 Create Kubernetes certificate CSR config file



cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "hosts": [
    "10.32.0.1",
    "10.240.0.8","kubelb",
    "10.240.0.2","master1",
    "10.240.0.3","master2",
    "10.240.0.4","master3",
    "10.240.0.5","164.90.180.233","worker1",
    "10.240.0.6","142.93.163.5","worker2",
    "10.240.0.7","64.225.109.190","worker3"
    "localhost",
    "127.0.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.svc.cluster.local",
    "164.90.166.195","kubelb.muratcabuk.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "NO",
      "L": "Oslo",
      "O": "Kubernetes",
      "OU": "Cluster",
      "ST": "Oslo"
    }
  ]
}
EOF


# 5.2 Generate the Kubernetes certificate and private key

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes


# After you execute the above code, you get the following additional files:

#kubernetes-csr.json
#kubernetes-key.pem
#kubernetes.pem

# 5.3 Verify the contents of the generated certificate:

openssl x509 -in kubernetes.pem -text -noout
```

son tahlilde şu dosylar oluşmuş oldu

- ca.pem
- ca-key.pem
- kubernetes-key.pem
- kubernetes.pem


__10. The ETCD Server Certificate__

çokç ok az kaynakta etcd servisi içinde sertifika üretimiyapılmış ancak bir çok kaynak api service için üretilen sertifikayı yeterli görmüş bir de bu yolu tercih ediyoruz ancak bunu yapmak isterseniz 2 kaynak

- https://github.com/mmumshad/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md#the-etcd-server-certificate
- https://github.com/Praqma/LearnKubernetes/blob/master/kamran/Kubernetes-The-Hard-Way-on-BareMetal.md#create-kubernetes-certificate-csr-config-file

__11. Sertifikaların Konulandırılması__

öncelikle bütün sertifikalarımızı files altındaki certificate_configs klasöründen certificate_files klasörüne taşıyalım.

canlı ortam için çıkan sertifika listesi (bide key dosyaları var)

- ca.pem
- admin.pem
- kube-controller-manager.pem (bunlar aslında master olmuş oluyor)
- kube-proxy.pem
- kube-scheduler.pem
- kubernetes.pem
- service-account.pem
- nginxlb-muratcabuk-com.pem (aşağıdaki LB için oluşturacağız)
- bunlarda kubelet ler aslında
  - worker1.pem 
  - worker2.pem
  - worker3.pem



Şimdi artık dosyalarımızı sunuculara kopyalayabiliriz.

Bunun için en çok kulanılan araç SCP. Windows için biz https://winscp.net/ sayfasındakşi SCP nin GUI versiyonu olan aracı kullanıyor olacağız. 

aracı kurduktan sonra File Protocol olara SCP seçip kubernetes sunucularımız ekliyoruz. password kısmını boş bırakıp advanceed ayarlardan private key inizi verebilirsiniz.

daha sonra sertifikalarımızı (yani pem dosylarımızı) sunucuda açacağımız bir kalsöre koyaplıyoruz. daha sonra ilgili yerlere taşıyacağız. şimdilik tün sertifikalrı tüm sunucular kopyalayabiliriz. ben home klasörü altına kubernetes diye bir klasör açarak oraya kopyaldım.


- https://medium.com/faun/configuring-ha-kubernetes-cluster-on-bare-metal-servers-monitoring-logs-and-usage-examples-3-3-340357f21453 (kesin bak)
- https://kubernetes.io/docs/setup/best-practices/certificates/

