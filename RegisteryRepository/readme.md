### Kurumlarda kaşılaşılabilecek hatalar

registery lere login olmada key save lernirken bir hata meydana geliyor 

```
Error saving credentials: error storing credentials - err: exit status 1, out: `Cannot autolaunch D-Bus without X11 $DISPLAY`
```

buu hatyı gidermek için alttaki komutu çalıştırınız.

```
apt install gnupg2 pass
```

eğer bu yöntem çalışmazsa 

stackoverflow da ki soruyu takip edebilirsiniz

- https://stackoverflow.com/questions/50151833/cannot-login-to-docker-account
- https://hasanyousuf.com/2019/09/21/how-to-install-sonatype-nexus-3-on-centos6-10/
- https://qiita.com/leechungkyu/items/86cad0396cf95b3b6973
- https://medium.com/@acokgungordu/nexus-repository-manager-3%C3%BC-depo-olarak-kullanma-docker-images-71ef1b2ccdea
- https://medium.com/@acokgungordu/nexus-repository-manager-3%C3%BC-depo-olarak-kullanma-docker-images-71ef1b2ccdea




### Kurulum

- https://qiita.com/leechungkyu/items/86cad0396cf95b3b6973
- https://help.sonatype.com/repomanager3/installation/installation-methods#InstallationMethods-InstallingwithDocker
- https://hub.docker.com/r/sonatype/nexus3/



1. docker ı kuruyoruz


https://docs.docker.com/engine/install/ubuntu/


```
# versiyon olarak 5:19.03.13~3-0~ubuntu-bionic kurduk

$  sudo apt-get install docker-ce=5:19.03.13~3-0~ubuntu-bionic docker-ce-cli=5:19.03.13~3-0~ubuntu-bionic  containerd.io

```

2. daha sonra nexus verileri için persistant volume oluşturuyoruz: 

- https://docs.docker.com/storage/volumes/
- https://hub.docker.com/r/sonatype/nexus3/#persistent-data

```
$ sudo docker volume create --name nexus-data
```

3. daha sonra alttaki komutla kuruyoruz

versiyon olarak nexus3:3.27.0 kuruyoruz. 

şu patha volume create edilmiş olacak.

var/lib/docker/volumes/nexus-data/

```
$ sudo docker run --name nexus -e INSTALL4J_ADD_VM_PARAMS="-Xms1g -Xmx1g -XX:MaxDirectMemorySize=2g" -d -p 5000:5000 -p 8081:8081 -v nexus-data:/nexus-data sonatype/nexus3:3.27.0

```

Daha sonra http://40.74.62.251:8081 adresinden bağlanabiliriz.



### Nexus 3 üzerinde docker repository sinde delete policy

https://help.sonatype.com/repomanager3/repository-management/cleanup-policies#CleanupPolicies-AssetNameMatcher

Published Before (Days):  belli bir günden önce oluşturulanları sil. yani en fazla kaç gün korunacağını belirtiyoruz. 30 olduğunu varsayalım
Last Downloaded Before (Days): belirlenen günden önce image kullanılmadıysa sil. 20 olduğunu varsayalım

örneğin bir image 25 gün önce create olmuş ancak 21 gündür kullanılmamış ozaman silinir.

uygulanan policy ler beraber çalışır.

### Nexus 3 üzerinde Docker Repository oluşturmak

- Öcelikle blob (storage) ouşturuyoruz. (üstte çark resmine tıklayıp soldaki menüden repoository ye tıklarsak görülebilir.)
- daha sonra soldan reporittory alttındaki repositories e tıklayıp oluşturabiliriz ya da hazırlardan kullanbiliriz.


8081 den 8090 a kadar portlat expose eilirse iyi olur. (her repo için bir porta ihtiyacımız olacak)

exus 3 web portu 8081, web sitesi için açılan herbir repository için port ataması yapmak lazım. 



Nexus u registery olarak kullancak olan **Docker**da http ile registery yapılmak isteniyorsa insecure regitery yapıması lazım öncelikle

- https://docs.docker.com/registry/insecure/

/etc/docker/daemon.json doyası create edilip (eğer değilse) alttaki bölüm eklnemeli

5000 portunu kendi (Nexus üzerinde) repomuzu create ederken girmiştik nexus 3 ekranında. Login olurken pu portu kullanıyoruz.

buradan şu çıkıyor her repo için bir port girmemiz lazım ya da group oluşturmak lazım.

```
{
  "insecure-registries" : ["privatereg.com:5000"]
}
```

buda dikkaet edilirse domain olarka privatereg.com yazıyor . Bu domaini docker sunucusunun host una yazlamalıyız. yani docker a bu adresteki 5000 portundan image alacağımızı veya image koyacağımızı söylemiş olduk. 

eğer image registery niniz docker ile aynı sunucudayda 127.0.0.1 diyebiliriz.


daha sonra 

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

öcelikle repoya login olmamız lazım

```
$ docker login -u admin -p admin123 privatereg.com:5000
```



- https://docs.docker.com/engine/reference/commandline/push/

örnek purh komutları

```

$ docker tag rhel-httpd:12.03 registry-host:5000/myadmin/rhel-httpd:12.04

$ docker push registry-host:5000/myadmin/rhel-httpd:12.04

```



### Jenkins kurulumu

docker hub da dikkat edilmeli yanlışlıkla sadece jenkins yazan image ları yükleme. Onlar deprecated artık yeni imaje larda jenkins/jenkins yazıyor. 

birde jebkins in yeni nesil UI i ve pipeline işlettme şekli olan blue ocean versiyonu var. onun registery adrsi farklı ve clasiğe göre bazı farklılıkları olduğı için niz clasik olan versiyonu yüklüyoruz.


jenkins makinasına aynı zamanda docker kurmuş olmalıyız zaen nexus u kurarken kullandığımız versionu jenkins makinaısnada kurduğumuz varsayıyoruz

```
$ adduser jenkins
$ cat /etc/passwd | grep jenkins

# sonuç

jenkins:x:1001:1001::/home/jenkins:/bin/bash

```
daha sonra bu id yi altta kullanacağız

birde var altıda jenkins_home diye bir klasör açıyoruz.




daha sonra log kısmını ayarlıyoruz

```
$ sudo -u jenkins cat > /var/jenkins_home/log.properties <<EOF
handlers=java.util.logging.ConsoleHandler
jenkins.level=FINEST
java.util.logging.ConsoleHandler.level=FINEST
EOF

```
klasöürn içindekilerle birlikte sahibini jenkins kullanıcısı yapıyoruz

```
$ sudo chown -R 1001:1001 /var/jenkins_home
```





```
$ sudo docker run --name myjenkins --restart unless-stopped -d -u 1001 -p 8080:8080 -p 50000:50000 --env JAVA_OPTS="-Djava.util.logging.config.file=/var/jenkins_home/log.properties" -v /var/jenkins_home:/var/jenkins_home jenkins/jenkins:2.249.1-lts-centos7
```

-d detach mode demektir, --rm stop olan container ı siler

eğer restart sttrategy belirlemediysek daha sonra bütün containerlarıda elle stop edilcene kadar restart etmesini sağlaycak kod

```
$  sudo docker update --restart unless-stopped $(sudo docker ps -q)

```



password için artık host makinasında alttaki komutu çalıştırabiliriz.

```
$ sudo cat /var/jenkins_home/secrets/initialAdminPassword
```

adres: http://13.95.194.157:8080/




### örnek hazır bir image ı tagleyip private registery mize push edelim ve daha sonra private registery den pull edelim.

https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images?view=aspnetcore-3.1

1. örnek uygulamayı clone la

```
$ git clone https://github.com/dotnet/dotnet-docker
```

2. Bocker image oluşturulur

dotnet-docker/samples/aspnetapp pathine gidiyoruz ve docker file ı nceliyoruz.

dockerfile da görüldüğü üzere buld alma işlemi de dcoker içinde yapılıyor.

```
# https://hub.docker.com/_/microsoft-dotnet-core
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetapp/*.csproj ./aspnetapp/
RUN dotnet restore

# copy everything else and build app
COPY aspnetapp/. ./aspnetapp/
WORKDIR /source/aspnetapp
RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "aspnetapp.dll"]
```


artık build alabiliriz.

```
$ docker build -t aspnetapp .
```

build sonucunda docker bize ya bir commit id verecek yada bu örnekte olduğu gibi latest olarak uygulamayı tag leyeek


build sonucu
```
Successfully built d60f075b69b1
Successfully tagged aspnetapp:latest
```

image listesini check ettiimizde de görebiliriz

```
$ docker image ls

# sonuç

REPOSITORY                             TAG                   IMAGE ID            CREATED             SIZE
aspnetapp                              latest                d60f075b69b1        2 minutes ago       212MB

```


3. daha sonra image ımızı tagliyoruz ve private registery mize push ediyoeuz. dikkat etmek lazım burada tag olarak version numarası da kullanıyor olacağız.



```
$ docker tag aspnetapp:latest privatereg.com:5000/aspnetapp:1.0.0

# tekrar image listesine bakacak olursak. socnuç

REPOSITORY                             TAG                   IMAGE ID            CREATED             SIZE
aspnetapp                              latest                d60f075b69b1        7 minutes ago       212MB
privatereg.com:5000/aspnetapp          1.0.0                 d60f075b69b1        7 minutes ago       212MB

```


daha sonra bu image ı push edebiliriz.

```
$ docker push privatereg.com:5000/aspnetapp:1.0.0
```

daha sonra Nexus 3 de check edecek olursak repositoey içinde aspnetapp 1.0.0 versiyonunu görebiliriz.

aynı latest ı tekrar version 2.0.0 olarak taglaeiyp push layıp naxusa bakacak olursak eski 1.0.0 olanın extradan 2.0.0 olarak da taglandiğini ve hash inin değişmediğini nexus panelinden görebiliriz


4. şimdi farkı bi veryion daha çıkabilmek için uygulamda biryerleri değiştirip terar build alıp taglarken 3.0.0 olarka tagleyeleim.



```
$ docker tag aspnetapp:latest privatereg.com:5000/aspnetapp:1.0.0

$ docker push privatereg.com:5000/aspnetapp:1.0.0

```


ufak bir değişiklik yapıp tag ıtekrar attığımızda yeni bir hash in oluştuğunu görebiliriz.

















