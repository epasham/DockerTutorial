
### STORAGE and VOLUME

https://docs.docker.com/storage/

1. Volume Mount
Volume mount edildiğinde host daki bir alan container ile paylaştırılmış olur.  Burada öenmli konu bind yöntemiyle aynıymış gibi görünse çalışma şekli biraz farklılıklar var.
   - birincisi ilgili folderın yönteimi tamammen dcker da ve host un temel fonsksiyonetisinden izole dilmiş durumdadır.
   - bind yönteminde container folder üzerinde herşeyi yapabilir. bu da güvenlik açığına sebebiyet verebilir.
   - oluşturulan bir volume birden fazla container ile paylaştırılabilir.
   - Volume ayrıca volume driver'ı da destekler böylece uzak hostlarda hatta clund da bile storage paylaştırmak mümkün olabilmektedir.
   - In addition, volumes are often a better choice than persisting data in a container’s writable layer, because a volume does not increase the size of the containers using it, and the volume’s contents exist outside the lifecycle of a given container.

![volume](files/types-of-mounts-volume.png)

2. Bind Mount
    burada valome dan farklı olarak voluem name değil bizaat hostdaki fiziksel path contaşner ile paylaştırılmış oluruz. ilgigli path yoksa otomatik create dilir.

    fakat şunu unutmamak lazım container host tarafında her türlü yazma, silem editleme yetkisine sahip olduğu için güvenlik problemi oluşturuabilir.

![volume](files/types-of-mounts-bind.png)

3. tmpfs Mount
    A tmpfs mount is not persisted on disk, either on the Docker host or within a container. It can be used by a container during the lifetime of the container, to store non-persistent state or sensitive information. For instance, internally, swarm services use tmpfs mounts to mount secrets into a service’s containers.

    
![volume](files/types-of-mounts-tmpfs.png)

4. named pipe
    an npipe mount can be used for communication between the Docker host and a container. Common use case is to run a third-party tool inside of a container and connect to the Docker Engine API using a named pipe.

### Good use cases for volumes
- Volumes are the preferred way to persist data in Docker containers and services. Some use cases for volumes include:

- Sharing data among multiple running containers. If you don’t explicitly create it, a volume is created the first time it is mounted into a container. When that container stops or is removed, the volume still exists. Multiple containers can mount the same volume simultaneously, either read-write or read-only. Volumes are only removed when you explicitly remove them.

- When the Docker host is not guaranteed to have a given directory or file structure. Volumes help you decouple the configuration of the Docker host from the container runtime.

- When you want to store your container’s data on a remote host or a cloud provider, rather than locally.

- When you need to back up, restore, or migrate data from one Docker host to another, volumes are a better choice. You can stop containers using the volume, then back up the volume’s directory (such as /var/lib/docker/volumes/volume-name).

### Good use cases for bind mounts
In general, you should use volumes where possible. Bind mounts are appropriate for the following types of use case:

- Sharing configuration files from the host machine to containers. This is how Docker provides DNS resolution to containers by default, by mounting /etc/resolv.conf from the host machine into each container.

- Sharing source code or build artifacts between a development environment on the Docker host and a container. For instance, you may mount a Maven target/ directory into a container, and each time you build the Maven project on the Docker host, the container gets access to the rebuilt artifacts.

- If you use Docker for development this way, your production Dockerfile would copy the production-ready artifacts directly into the image, rather than relying on a bind mount.

- When the file or directory structure of the Docker host is guaranteed to be consistent with the bind mounts the containers require.

### Good use cases for tmpfs mounts
tmpfs mounts are best used for cases when you do not want the data to persist either on the host machine or within the container. This may be for security reasons or to protect the performance of the container when your application needs to write a large volume of non-persistent state data.





#### VOLUMES
https://docs.docker.com/engine/reference/builder/#volume

https://docs.docker.com/storage/volumes/


![volume](files/types-of-mounts-volume.png)



1. __Choose the -v or --mount flag__
Originally, the -v or --volume flag was used for standalone containers and the --mount flag was used for swarm services. However, starting with Docker 17.06, you can also use --mount with standalone containers. In general, --mount is more explicit and verbose. The biggest difference is that the -v syntax combines all the options together in one field, while the --mount syntax separates them. Here is a comparison of the syntax for each flag.

    New users should try --mount syntax which is simpler than --volume syntax.

    If you need to specify volume driver options, you must use --mount.

   - -v or --volume: Consists of three fields, separated by colon characters (:). The fields must be in the correct order, and the meaning of each field is not immediately obvious.
     - In the case of named volumes, the first field is the name of the volume, and is unique on a given host machine. For anonymous volumes, the first field is omitted.
     - The second field is the path where the file or directory are mounted in the container.
     - The third field is optional, and is a comma-separated list of options, such as ro. These options are discussed below.
   - --mount: Consists of multiple key-value pairs, separated by commas and each consisting of a [key]=[value] tuple. The --mount syntax is more verbose than -v or --volume, but the order of the keys is not significant, and the value of the flag is easier to understand.
     - The type of the mount, which can be bind, volume, or tmpfs. This topic discusses volumes, so the type is always volume.
     - The source of the mount. For named volumes, this is the name of the volume. For anonymous volumes, this field is omitted. May be specified as source or src.
     - The destination takes as its value the path where the file or directory is mounted in the container. May be specified as destination, dst, or target.
     - The readonly option, if present, causes the bind mount to be mounted into the container as read-only.
     - The volume-opt option, which can be specified more than once, takes a key-value pair consisting of the option name and its value.

__Differences between -v and --mount behavior__

As opposed to bind mounts, all options for volumes are available for both --mount and -v flags.

When using volumes with services, only --mount is supported.

aslında mount ile veya volume keyword u ile volume bağlamnın bir farkı yok ancak swarm da sadece mount kullanılabilirken docker container da ikisi de kullanılabilir.

burada her ikisini de örneklyeceğiz.

2. __Örnekler__

```shell
$ docker volume create myvol2

# mount with volume
$ docker run -d \
  --name devtest \
  -v myvol2:/app \
  nginx:latest

# mount with mount
$ docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest

```
read only volume
```
# mount version

$ docker run -d \
  --name=nginxtest \
  --mount source=nginx-vol,destination=/usr/share/nginx/html,readonly \
  nginx:latest

# volume version

$ docker run -d \
  --name=nginxtest \
  -v nginx-vol:/usr/share/nginx/html:ro \
  nginx:latest

```

docker inspect nginxtest

```
"Mounts": [
    {
        "Type": "volume",
        "Name": "nginx-vol",
        "Source": "/var/lib/docker/volumes/nginx-vol/_data",
        "Destination": "/usr/share/nginx/html",
        "Driver": "local",
        "Mode": "",
        "RW": false,
        "Propagation": ""
    }
],
```

3. __Volume Driver__
bunun için plugin kukllanılmaktadır. böylece docker exted edileniliyor. bunun gibi başka plunginlerde mevcut.

   - https://docs.docker.com/engine/extend/legacy_plugins/
   - https://docs.docker.com/engine/extend/plugins_volume/

bunun için driverın tipi yazılır. default da driver tipi local dir aslında oda bir plugin ve gömülü geliyor.

örnek 

```
#tempfs kısmında daha detyalı incelenek aslında ama örnek tuttuğu için ekledim
$ docker volume create --driver local \
    --opt type=tmpfs \
    --opt device=tmpfs \
    --opt o=size=100m,uid=1000 \
    foo


$ docker volume create --driver local \
    --opt type=btrfs \
    --opt device=/dev/sda2 \
    foo

# NFS kullanımı
$ docker volume create --driver local \
    --opt type=nfs \
    --opt o=addr=192.168.1.1,rw \
    --opt device=:/path/to/dir \
    foo

```

mesela plugin listesinden  local-persist prluginini kurduğumuzu varsayalım.

- https://github.com/MatchbookLab/local-persist

local driver ına göre artısı

This has a few advantages over the (default) local driver that comes with Docker, because our data will not be deleted when the Volume is removed. The local driver deletes all data when it's removed. With the local-persist driver, if you remove the driver, and then recreate it later with the same command above, any volume that was added to that volume will still be there.

```
$ docker volume create -d local-persist \
    -o mountpoint=/data/images \
    --name=images
```

diğer bir örnek Gluster Kullanımı
- https://www.ionos.com/community/server-cloud-infrastructure/docker/using-gluster-for-a-distributed-docker-storage-volume/

```
sudo docker run -it --volume-driver glusterfs -v media:/mnt centos /bin/bash
```

### BIND MOUNT


![volume](files/types-of-mounts-bind.png)


burada da volume ve mount seçenklri mevcut. mount da daha fazla yetenek var. 

aslında tek farkı mount type mount tipinde iken bind olarak ayarlıyoruz. 

temel fatkı voluöe maount a göre, burada kaynak ve hedef folder patj olarak direk yazılıyor.

volume tipinde de container içindeki bir yolu host üzerindeki bir yola bağladığımızı çaıkça yazıyoruz. 

örnek olarak

```
$ docker run -d \
  -it \
  --name devtest \
  --mount type=bind,source="$(pwd)"/target,target=/app,readonly \
  nginx:latest
```
daha fazla detay için 

- https://docs.docker.com/storage/bind-mounts/


### TMPFS MOUNT

Volumes and bind mounts let you share files between the host machine and container so that you can persist data even after the container is stopped.

If you’re running Docker on Linux, you have a third option: tmpfs mounts. When you create a container with a tmpfs mount, the container can create files outside the container’s writable layer.

As opposed to volumes and bind mounts, a tmpfs mount is temporary, and only persisted in the host memory. When the container stops, the tmpfs mount is removed, and files written there won’t be persisted.



![volume](files/types-of-mounts-tmpfs.png)



örnek

```

# Mount version
$ docker run -d \
  -it \
  --name tmptest \
  --mount type=tmpfs,destination=/app \
  nginx:latest

# tmpfs version

$ docker run -d \
  -it \
  --name tmptest \
  --tmpfs /app \
  nginx:latest

  ```


### STORE DATA WITHIN CONTAINERS

dockerfile da herbir FROM, RUN, SHELL vb komut image içine layer oluşturur ve buda işlenerek son tahlilde image i ve dolasyısla container ı oluşturur. burada yapılan işlmelrde imaeg içine dosyalar oluşturur.  ayrıca container çalışmaya başladıktan sonrada direct olarka container içine dosya create etmek mümkün. bu kısım bu dosya sisteminin nasl çalışacağını ya da çalıştırılacağını anlatır. çok çok elzem olmadıkça dokunulmması gereken bir yer.

detaylar için sayfa: https://docs.docker.com/storage/storagedriver/select-storage-driver/


- Docker supports the following storage drivers:
    - __overlay2__ is the preferred storage driver, for all currently supported Linux distributions, and requires no extra configuration.
    - __aufs__ is the preferred storage driver for Docker 18.06 and older, when running on Ubuntu 14.04 on kernel 3.13 which has no support for overlay2.
    - __devicemapper__ is supported, but requires direct-lvm for production environments, because loopback-lvm, while zero-configuration, has very poor performance. devicemapper was the recommended storage driver for CentOS and RHEL, as their kernel version did not support overlay2. However, current versions of CentOS and RHEL now have support for overlay2, which is now the recommended driver.
    - The __btrfs__ and zfs storage drivers are used if they are the backing filesystem (the filesystem of the host on which Docker is installed). These filesystems allow for advanced options, such as creating “snapshots”, but require more maintenance and setup. Each of these relies on the backing filesystem being configured correctly.
    - The __vfs__ storage driver is intended for testing purposes, and for situations where no copy-on-write filesystem can be used. Performance of this storage driver is poor, and is not generally recommended for production use.













## Distributed Storages


https://medium.com/commencis/docker-serisi-3-docker-engine-bolum-2-a7c6c5f50851#295b


volume için birçok seçenek var ancak eğer çok yoğun bir dosya ihtiyacı yoksa NFS en pratik çözüm gibi duruyor.

Ceph kurulumunu test ettim ansible ile kurulumu çokta zor değil gibi. Ancak octobus için bir tane aracın debian sürümü çıkmadıı için bu versiyonda NFS testi yapamadım

https://download.nfs-ganesha.org/3/3.2/ (bunun 3.2 sürümü ubuntu için yok)


Ceph ile alakalı detaylı bilgi için

https://github.com/muratcabuk/Notes/tree/master/StorageSystems

windows için volume örneği : https://4sysops.com/archives/introduction-to-docker-bind-mounts-and-volumes/



