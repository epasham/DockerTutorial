öncelikle example ikiyi okumanızı tavsiye ederim. bazı konuarın ayrıntıların aorada değinildi.

example 1 de olduğu gibi yine build alıp registery ye göndereceğiz



1. öcelikle hazıladığımız docker-compose dosyasını build alıyoruz ve docker-compose up ile ayağa kadırarak çalıştığındna emin oluyoruz. uygulamda asp.net core uygulamsı redis e bağlanrak redis info bilgisi çekiyor.

ancak bu adımı atlayabilirsiniz eğer example 1 i yaptıysanız zaten çalıştığını göremüşsünüzdür.

```
docker-compose build .
docker-compose up
```
2. azure registery kullanacağımız için öncelikle login oluyoruz


```
docker login madmin.azurecr.io
```

daha sonra build aldığımız compose servisimizi pushluyoruz.

```
docker-compose push 
```

burada insecure registery durumunu yaşamayacağız çünki azure registery kullanıyoruz ve bu https le çalışıyor.

3. bu adımda local registery de olan imagelerı kulanarak swarm moddda servilerimizi ayağa kaldırıyoruz.


```
docker stack deploy --compose-file docker-compose.yml myaspnetproject
```

karşılaşabilceğimiz halarla ilgili olarak

çalışan tüm container ların kullanığı portları listelemek için

```
docker port $(docker container ls -q)
```
linux deki tüm açık portlar

```
sudo netstat -tunlp


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



hata yaptığmız durumlarda docker-compose ile registry den image silmek için eğer kullanığımız cli push ve pull dışında bşir araç sunmuyorsa tek şansımız registry API kullanmaktır.

https://docs.docker.com/registry/spec/api/#deleting-an-image


çalışan service in hangi taskleri hangi nodelar üzerinde çalıştırdığını görmek için

```
docker service ps servicename/serviceid
```

4. çalışan servislerin listesini almak için

```
docker service ls
```

listedeki bir servisi scale etmek için

```
docker service scale servicename:replicacount

yada 

 docker service update --replicas=50 servicename

```
tam bu esnada bzaen ilgili image in bulunamadığı ile ilgili bir hata alınabilir.
çözümü üçin



