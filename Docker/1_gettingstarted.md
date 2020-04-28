###  __Hello-World__


kesin bakılmalı
https://www.bgasecurity.com/2018/04/dockerin-calistigi-host-uzerinde-yapilmasi-gereken-sikilastirmalar/



temel olarak ya dockerfile yazıp kendi image ımızı oluşturuz ve bunu publi yada private bir register i ye koyuyoruz her defaısnda build yapmamak için. daha sonra docker komutlarıyla bunu çalıştırıyoruz.

eğer birden fazla docker ile birilikte bir sistem oluşturuyorsak (web, database, storage, vb) ozaman dockercompose file yazıyoruz yaml tabanlı.  docker-compose cli ile bütün sistemi toplu halde yöntiyoruz.

bir orchestrasyona ihtiyacımız olduğunda da swarm kullanıyoruz (dikkat cluster demedim.) Ancak cluster sız swarm dününelemz herhalde. bu durumda birden fazla sunucuya bağlanarak bir cluster oluşturuyoruz. swarm bu cluster ı bir nevi tek bir makinaymış gibi kaynaklarını bize sunuyor. bunun haricinde bir scheduler ve orcherstrator olarak da çalışıyor.

swarm ın işelerini yötebilmesi içinde docker stack kulanılıyor. buda yaml tabanlı bir dosya. yoksa cli üzerinden yönetilebilir ancak bu baya yorucu olacaktır. düşünü siste göçtü herşeyin komutunu yazmak durumunda kalacağız. ancka elimizde sistemin anlık durumunu gösteren bir yaml dosyası olas ve biz emri ona versek tüm sistem ayağa kaldırılabilir tekrar. ayrıca swarm a özel işlerde bu dosya yarımıyla halledilir, örneğin a sersinin kaç replice olacağı hangi durumlarda restart olacağı vb.

burada bahsi geçen yaml tabanlı doyalar aslında configurasyon management sağlıyor bize. Ayrıca declerative yöntem sunmuş oluyor bize ayrıca canlı bir döküman olmuş oluyor. anlık olark sistemin durumunu görmüş oluyoruz. imperative yol ise CLI kullanmak.

kubernetes aslında swarm ın yerini aLmış oluyor burada. orada da imperative yol kubectl kullanmak declarative yol ise yine yaml tabanlı bir sistem. burada kubernetes in configurasyon sistemi yeterli gibi görünüyor fakat aslında yeterli olmaycaktır çünki kubernetes configurasyon sistemi sadece containerlarla ve ve compose dosyasındaki toplu servislerle ilgineri. Halbuki kubernetes de bunların dışında bir çok bileşen ve bunların konfigürasyonu var (Pods, Services, Ingresses, configMaps, Secrets, Volumes). yani sadee oluşturlarn instance lar değil daha bir çok configuasyon gerektiren konu var burada da devreye HELM giriyor.


https://www.magalix.com/blog/kubernetes-configuration-management-101

https://blog.argoproj.io/the-state-of-kubernetes-configuration-management-d8b06c1205


``` docker
docker run hello-world

```

bunu yaptığımızda image doxcker hub dan indirilip sadece bir kez çalıştırlıp kapatıldı.

çalışıp kapanan containerları gömek için _docker ps -a_ ya da neni versiyonuyla _docker container ls -a_ kullanılır.

container hakkında detaylı bilgi almak için _docker inspect <container_id>_ kullanılır.

şimdi aşağıdaki komutla nginx i çalıştıralım.

``` docker
docker run -p 8080:80 nginx:1.10
```
bu komut ile aslnda docker üzriendeki 80 portunu host üzerindeki 8080 portuna bağlamış olduk .yani biri eğer ana makina üzerinde localhost:8080 derse nginx docker üzerindeki 80 portu çalışmaya başlamış olacak.

docker container üzeridne yeni tty açıp içeride neler olduğun abakabiliriz bunun için alttakşi komutu çalıştırmalıyız.

``` docker
docker exec -it <container_id> /bin/bash 
```
yalnız burada dikkat edilirse uygulama bizim terminaliizi lock ladı sebebni ise hello_world image ı ekran ahello worl yazdıktan sonra işi biten bir container dı bu ise devamlı çalışan bşir servis. bu durumda run komutuna -d parametresini de eklmek doğru olacaktır yani terminal detached olarka çalışacaktır. 

container açıldıktan sonra _ps_ komutu ile çalışan servis ve uygulamalrı görebiliriz. Görüleceği üzere sadece nginx çalışmaktadır. Nginx kondigürasyon dosyasın abakaca olursak _/etc/nginx/conf.d/default.conf_ 80 portunun dinlendiği görülebilir.
