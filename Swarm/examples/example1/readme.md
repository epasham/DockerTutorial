bu uygulama compose ile birlikte build yapılmasını konu alıyor.

swarm ile bu compose dosyası ile service leri ayağa kaldırmış olacağız.

ayrıca ikinci bir versiyonla azure uzerindeki docker registry ye compose image leri konulup oradanda çalışcak örnek yapılacak.

şuan için dış bir registery miz olmadığı için bu komutları swarm clusterınızdaki bir makinada çalıştırıyor olcağız.


burada şunu unutmamak lazım swarm mod yokken biz docker name ile ulaşabiliyorduk containerlarımıza, dolayısıyle servislerimize ancak burada herşey servis olduğu için servis isimlerini kullanmamız lazım artık.


1. öcelikle hazıladığımız docker-compose dosyasını build alıyoruz ve docker-compose up ile ayağa kadırarak çalıştığındna emin oluyoruz. uygulamda asp.net core uygulamsı redis e bağlanrak redis info bilgisi çekiyor.

```
docker-compose build .
docker-compose up
```
2. çalıştığın emin olduktan sonra örneğimizde local registery ye (127.0.0.1) e imageımızı docker-compose push ile deploy ediyoruz. çünki docker stack build alamıyor sadece registery den okuyabiliyor.

bu nedenle compose doyasına baklırsa hem dockerfile belirtildi hemde registery

öncelikle eğer yoksa local private bir registery ayağ akaldırıyoruz

bizde host da 5000 portu dolu olduğu için 5003 e yaraldık

```
$ docker run -d -p 5003:5000 -v /mnt/registry:/var/lib/registry --restart=always --name registry --rm registry:2
```
daha sonra bu registery ye push luyoruz container ımızı


```
docker-compose push 
```

ancak bu komutu çalıştırdığımızda registry miz local host  da olmadığı içn https isteyecektir docker daemon bununla uğraşmamak için docker daemon ayarlarında http ye (insecure) izin vermek için alttaki ayarı yapıyoruz.

https://docs.docker.com/registry/insecure/#deploy-a-plain-http-registry

```
sudo nano /etc/docker/daemon.json

# add following rows

{
  "insecure-registries" : ["myregistrydomain.com:5000"]
}

```



registery de liste almak için

```
wget http://localhost:5003/v2/_catalog && less _catalog
```


3. bu adımda local registery de olan imagelerı kulanarak swarm moddda servilerimizi ayağa kaldırıyoruz.


çalışan tüm container ların kullanığı portları listelemek için

```
docker port $(docker container ls -q)
```
linux deki tüm açık portlar

```
sudo netstat -tunlp
```

-t Show TCP ports.
-u Show UDP ports.
-n Show numerical addresses instead of resolving hosts.
-l Show only listening ports.
-p Show the PID and name of the listener’s process.


```




yada ss i kullanabiliriz

```
sudo ss -tunlp
```



```
docker stack deploy --compose-file docker-compose.yml myaspnetproject
```

hata yaptığmız durumlarda docker-compose ile registry den image silmek için eğer kullanığımız cli push ve pull dışında bşir araç sunmuyorsa tek şansımız registry API kullanmaktır.

https://docs.docker.com/registry/spec/api/#deleting-an-image



