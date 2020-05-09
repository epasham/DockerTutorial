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

```
$ docker run -d -p 5003:5003 -v /mnt/registry:/var/lib/registry --restart=always --name registry --rm registry:2
```
daha sonra bu registery ye push luyoruz container ımızı


```
docker-compose push 
```


3. bu adımda local registery de olan imagelerı kulanarak swarm moddda servilerimizi ayağa kaldırıyoruz.




```
docker stack deploy 









