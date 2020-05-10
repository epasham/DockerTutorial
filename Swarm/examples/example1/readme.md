bu uygulama compose ile birlikte build yapılmasını konu alıyor.

swarm ile bu compose dosyası ile service leri ayağa kaldırmış olacağız.

ayrıca ikinci bir versiyonla azure uzerindeki docker registry ye compose image leri konulup oradanda çalışcak örnek yapılacak.

şuan için dış bir registery miz olmadığı için bu komutları swarm clusterınızdaki bir makinada çalıştırıyor olcağız.


1. öcelikle hazıladığımız docker-compose dosyasını build alıyoruz ve docker-compose up ile ayağa kadırarak çalıştığındna emin oluyoruz. uygulamda asp.net core uygulamsı redis e bağlanrak redis info bilgisi çekiyor.

```
docker-compose build .
docker-compose up
```
2. çalıştığın aemin oladuktan sonra örneğimizde local registery ye (127.0.0.1) e imageımızı docker-compose push ile deploy ediyoruz. çünki docker stack build alamıyor sadece registery den okuyabiliyor.

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


