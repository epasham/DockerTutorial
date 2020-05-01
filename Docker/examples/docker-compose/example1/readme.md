ENV, ARG ve VOLUME örneği içermektedir.

image create edilirken yan ibuild edilirken ARG verilir parametre olarka container ayağa kaldırılırkende env sile yada parametre aolark ENV ler geçirilir.
yada image create olurken ENV ler doldurulsun istiyorsak ozman ARG ı ENV ebağlamak gerekiyor.


direk dockerfile üzerinden gitmek istenirse 

1. öncelikle project1 build alınmalı çünkü poeject2 project1 e bağımlı
   
project1 klasöründe iken

https://docs.docker.com/engine/reference/commandline/build/#options

```
docker build . -t murat/project1:latest --build-arg UBUNTU_VERSION=18.04 --build-arg VOLUME_PATH_ARG=/home/temp --build-arg VOLUME_NAME_ENV=myvolume
```

daha sonra container ayağa kaldırılır. ancak bizim uygulamamız cotainer ın ayakta olmasını istiyor ve Dockerfile ımıza göre containerımız hemen kapancak. ,
onu ayakta tutmak için bin/bash ile açacağız ancak background a çalışıyor olacak. -d parametresi detached modda çalıştırır -a dersek (ki vaasayılan budur) docker terminali bizim terminalimize attach eder.

atach ederken run tim eolduğu için ENV parametresinide veriyoruz dikkat (--env-file p1.env).
ENV vermenin diğer bir yolu ise --env var1=value1 şeklinde direkt vermektir.


```
docker run -d -it --env-file p1.env --rm  --name project1 murat/project1:latest bash
```

şimdi sıra ikinci projeyi çalıştımakta

öncelikle projemizi build ediyoruz.

```
docker build . -t murat/project2:latest
```

daha sonra çalıştırıyoruz. fakat bu sefer project2 nin terminalinin attach olmasını istiyoruz bu nedenle -d paramatesini kaldırdıkö yani default ola -a çalışmış olacak.

```
docker run  -it --rm  --name project2 murat/project2:latest bash
```