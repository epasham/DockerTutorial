
https://docs.docker.com/compose/compose-file/

### installation


adımları tek tek çalıştırınız

```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
$ docker-compose --version
```

unistall yapmak için

```
sudo rm /usr/local/bin/docker-compose
pip uninstall docker-compose
```

### Örnek İnceleme
aşağaıdaki adreste voting app orneği var.

- https://github.com/dockersamples/example-voting-app
- Commit Id: Latest commit  245c8f3 on 19 Feb

bu döküman hazırlanırken çalışan üstteki commit numarınuı içeren veryonun fork versiyonu 
- https://github.com/muratcabuk/example-voting-app

docker compose version

- docker-compose version 1.25.5, build 8a1c60f6
- docker-py version: 4.1.0
- CPython version: 3.7.5
- OpenSSL version: OpenSSL 1.1.0l  10 Sep 2019

docker version

- Client: Docker Engine - Community
  - Version:           19.03.8
  - API version:       1.40
  - Go version:        go1.12.17
  - Git commit:        afacb8b7f0
  - Built:             Wed Mar 11 01:25:46 2020
  - OS/Arch:           linux/amd64
  - Experimental:      false

- Server: Docker Engine - Community
- Engine:
  - Version:          19.03.8
  - API version:      1.40 (minimum version 1.12)
  - Go version:       go1.12.1
  - Git commit:       afacb8b7f
  - Built:            Wed Mar 11 01:24:19 2020
  - OS/Arch:          linux/amd64
  - Experimental:     false
- containerd:
  - Version:          1.2.1
  - GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
- runc:
  - Version:          1.0.0-rc10
  - GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
- docker-init
  - Version:          0.18.
  - GitCommit:        fec3683

bu compose un içeriği incelendiği kuberntes, swar ve windows versiyonlarınında yazılmış olduğu görülecektir.

bu projeyi bilgisayarımıza indirdikten sonra klasör içinde iken _docker-compose up_ dersek ugulama çalışaktır. taklırsa iki defa komut çalıştırılmalı.  _docker-compose down_ dersek bütün kaynaklarıyla birlikte contaşner lerı siler.

bu örnkte kaynak kodlarda projede var ancak yaml dosyasında bütün imageler docker hub dan çekliecek şekilde yazılmış. yaml dosyası değiştirilerek build alınarak da yapılabilir aynı uygulama.
örneğin Gökhan hoca kendi sayfasında aynı örneği bu şekilde çalıştırmış.

uygulama içinde worker, result ve voting olmak üzere 3 klasör var. bu üç klasörde python, nodejs, dotnet ve java tabanı uygulamalr var bir çoğunun tüm  dillerde yazılmış versiyonlarıda mevcut. ancak default docker-compose.yml dosyası aşağıdaki kurguda çalışıyor. bütün bu sunucuları bu dosya tek seferde ayağa kaldırıyor.

![vote app](files/voteapp.png)


- https://gokhansengun.com/docker-compose-nasil-kullanilir/

worker kısmına bakılırsa build yapıldığı görülür.

```yaml
version: "2"

services:
   voting-app:
      build: ./vote
      command: python app.py
      volumes:
         - ./vote:/app
      ports:
         - "5000:80"
     
   redis:
      image: redis:alpine
      ports: ["6379"]
         
   worker:
      build: ./worker
            
   db:
      image: postgres:9.4
    
   result-app:
      build: ./result
      command: nodemon --debug server.js
      volumes:
         - ./result:/app
      ports:
         - "5001:80"
         - "5858:5858"
```



### docker-compose.yml file organization

- https://www.linode.com/docs/applications/containers/how-to-use-docker-compose/

Bir docker-compose.yml dosyası 4 bölümden oluşmaktadır.

1. Version: yaml dosyasının syntax i için gerekli ola versyon nmrası. compose geliştikçe yeni keywordler kelendiği için gerekli.
2. Services: yeönetilmek istenen containerın bulunduğu bölüm.
3. Networks: uyugulama için gerekli olan network konfigurasyonu, default network ayarları buradan değiştirilebilir.
4. Volumes: gerekli olan volume/storage ayarları.

services bölümünde ençok kullanılan direktifler.

- image:	Sets the image that will be used to build the container. Using this directive assumes that the specified image already exists either on the host or on Docker Hub.
- build:	This directive can be used instead of image. Specifies the location of the Dockerfile that will be used to build this container.
- db:	In the case of the example Dockercompose file, db is a variable for the container you are about to define.
- restart:	Tells the container to restart if the system restarts.
- volumes:	Mounts a linked path on the host machine that can be used by the container
- environment:	Define environment variables to be passed in to the Docker run command.
- depends_on:	Sets a service as a dependency for the current block-defined container
- port:	Maps a port from the container to the host in the following manner: host:container
- links:	Link this service to any other services in the Docker Compose file by specifying their names here.

daha birçok keyword için : https://docs.docker.com/compose/compose-file/


### Kaynaklar

- https://docs.docker.com/compose/
- https://docs.docker.com/compose/aspnet-mssql-compose/
- https://docs.docker.com/samples/
- https://docs.docker.com/samples/#tutorial-labs
- https://gokhansengun.com/docker-compose-nasil-kullanilir/