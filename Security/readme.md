### OWASP Top 10

- [TOP 10 Güvenlik Zaafiyeti Listesi](https://github.com/OWASP/Docker-Security/blob/master/D00%20-%20Overview.md)
- [Top 10 Güvenlik Zaafiyetleri Korunma Teknikleri](https://github.com/OWASP/Docker-Security)
- [Top 10 Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)


### Docker Resmi Web Sayfları

- [Security Ana Sayfası](https://docs.docker.com/engine/security/)



### AppArmor

AppArmor, Linux dağıtımlarında kullanılan, SeLinux benzeri bir güvenlik modülüdür. Docker'ın kullanabilceği bir AppArmor profili ve kural oluşturulur. Daha detaylı bilgi ve Docker'da  kullanımı için [şu sayfayı](AppArmour.md) ziyaret ediniz.

### SecComp

https://docs.docker.com/engine/security/seccomp/


### Docker Bench 

CIS standartlarını içeren Docker Güvenlik ve audir yaplnadırmalarını otomatik olarak kontrol ederek kullanıcıya rapor sunan Bash ile yazılmış açık kaynak bir scripttir.

- https://dev-sec.io/baselines/docker/
- https://dev-sec.io/

```
$ Docker pull docker/docker-bench-security
# veya
$ git clone https://github.com/docker/docker-bench-security.git
# çalıştırmak için

$ ./docker-bech-security.sh

```


### Kubernetes

- https://dev-sec.io/baselines/kubernetes/
- https://dev-sec.io/#



### Resource

- https://www.bgasecurity.com/2018/04/dockerin-calistigi-host-uzerinde-yapilmasi-gereken-sikilastirmalar/


### 

Docker, yazılımları container adı verilen paketler halinde sunmak için işletim sistemi düzeyinde sanallaştırmayı "Platform as a Service" (PaaS) ürünleri kümesidir. Container'lar birbirinden izole edilmiştir ve kendi yazılımlarını, kitaplıklarını ve yapılandırma dosyalarını bir araya getirir; iyi tanımlanmış kanallar aracılığıyla birbirleriyle iletişim kurabilirler. Tüm container'lar tek bir işletim sistemi çekirdeği tarafından çalıştırılır ve bu nedenle sanal makinelerden daha az kaynak kullanır.

Bu tanımladan yola çıkarak bir işletim sistemi üzerinde çalışan, birbirinden izole ancak gerektiğinde birbirleriyle iletişime geçebilen proseslerin beklenen güvenli ortamı sunabikmesi gerekmektedir.

Bu konuda OWASP'ın (Open Web Application Security Project) sunmuş olduğu Top 10 Best Practice'ler ve Docker resmi sitesinde yer alan aşağıdaki önlemlerin alınması önem arzetmektedir.

- Container'lar yönetici (root) hesabıyla çalıştırılmamalı.
- Update'ler düzenli kontrol edilmeli ve özellikle güvenlik yamaları yapılmalı.
- Container'ların network izolasyonu dikkatli yapılmalı.
- Gizli bilgiler konfigürasyon içine clean text olarak yazılmamalı.
- Private registery ihtiyacı varsa SSL kullanılmalı.
- Public repolardan kullanılan Docker image'lar onaylı resmi image'lardan seçilmeli.
- Docker container'ın host işletim sistemi üzeride yapabilcekleri sınırlandırılmalı.
- Container'ların kaynak tüketimleri limltlenmeli
-  

https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html madde 3 de kaldın alttaki kaynakalra da bak


gizili blgiler  

### Kaynaklar
- https://github.com/OWASP/Docker-Security/blob/master/D00%20-%20Overview.md
- https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html
- https://docs.docker.com/engine/security/
- https://docs.docker.com/engine/security/seccomp/
- https://dev-sec.io/baselines/docker/