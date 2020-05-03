ENV, ARG ve VOLUME örneği içermektedir.

image create edilirken yan ibuild edilirken ARG verilir parametre olarka container ayağa kaldırılırkende env sile yada parametre aolark ENV ler geçirilir.
yada image create olurken ENV ler doldurulsun istiyorsak ozman ARG ı ENV ebağlamak gerekiyor.


direk dockerfile üzerinden gitmek istenirse.

#### Birinci Yöntem

1. öncelikle project1 build alınmalı çünkü poeject2 project1 e bağımlı
   
project1 klasöründe iken

https://docs.docker.com/engine/reference/commandline/build/#options

```
docker build . -t murat/project1:latest --build-arg UBUNTU_VERSION=18.04
```

daha sonra container ayağa kaldırılır. ancak bizim uygulamamız cotainer ın ayakta olmasını istiyor ve Dockerfile ımıza göre containerımız hemen kapancak. ,
onu ayakta tutmak için bin/bash ile açacağız ancak background a çalışıyor olacak. -d parametresi detached modda çalıştırır -a dersek (ki vaasayılan budur) docker terminali bizim terminalimize attach eder.

Ancak daha sonra entrypoint içine  _tail -f /dev/null_ komutu eklendi yani -d parametresi bash ve -d eklenmese de olur. 

atach ederken run tim eolduğu için ENV parametresinide veriyoruz dikkat (--env-file p1.env).
ENV vermenin diğer bir yolu ise --env var1=value1 şeklinde direkt vermektir.


```

docker volume create myvolume
docker run -d -it --env-file p1.env --rm  --name project1 --network bridge --mount source=myvolume,target=/home/myvolume murat/project1:latest bash
```

şimdi sıra ikinci projeyi çalıştımakta

öncelikle projemizi build ediyoruz.

```
docker build . -t murat/project2:latest
```

daha sonra çalıştırıyoruz. fakat bu sefer project2 nin terminalinin attach olmasını istiyoruz bu nedenle -d paramatesini kaldırdıkö yani default ola -a çalışmış olacak.

```
docker volume create myvolume
docker run  -it --rm  --name project2 --network bridge --mount source=myvolume,target=/home/myvolume murat/project2:latest bash
```


#### İkinci Yöntem

Bunun için compose file kullacağız. daha önce docker file üzerinden parametre olarka geçtiğimiz volume, network ve arg bilgilerini artık docker compose dosyasına yazacağız ve docker-compose cli üzerinde up komutu ile çalıştırıyor olacağız.


öcelikle build yapmamız gerekiyor
```
docker-compose build
```
daha sonra docker up diyerek octainerları ayağa kaldırıyoruz

```
docker-compose up
```
oluşturulan bütün kaynakları da silerek container ları kaptmak istiyorsak docker-compose down dememzi yeterli ancak alttaki maddlere dikkat!!!!

Stops containers and removes containers, networks, volumes, and images created by up.

By default, the only things removed are:

- Containers for services defined in the Compose file
- Networks defined in the networks section of the Compose file
- The default network, if one is used
- Networks and volumes defined as external are never removed.




