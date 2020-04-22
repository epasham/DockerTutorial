###  __Hello-World__

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

### __Dockerfile__

dockerfile best practices

- https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- https://docs.docker.com/engine/reference/builder/


1. RUN: docker image build lurken çalışır
2. CMD: build işlemi bittikten sonra docker container ayağa kaltığında çalışır. Komut satırında docker image dan container ayağa kaldırılşıp çalıştırılırken cli ın ezilerek CMD dedeki komutun çalışması sağlanır. bir docker file da sadece bir adet CMD bulunmalıdır.
  
CMD birkaç farklı şekilde yazılabilir.

- CMD [ "executable", "param1", "param2" ]
- CMD [ "param1", "param2" ] // entrypoint in işaret ettiği yerde bir executable var zaten ona işaret emiş oluruz.
- CMD command param1 param2

3. ENTRYPOINT: Eğer oluşturlan image belli bir excutable un parametre alarak çalışcağı bir uygulam ise, ENTRYPOINT ilgili executable olduğu yerde bırakılırsa sadece parametre vererek container  ı ayağa kaldırmak mümkün olcaktır.

- ENTRYPOINT [ "/bin/ping" ]  // buradada bırakılırsa dockerfile içinde

aşağıdaki şekilde ping executable ı yazılmadan çağrılabilir. bu arada bestpractice bu şekilde.

- docker run ubuntu 8.8.8.8

4. ADD: image a local den dosya kopyalamak için kullanılır. COPY den farklı oarak internetteen bira adrestedn de indirebilir.
   
 - ADD ["src",... "dest"]

5. WORKDIR: aktif olarak RUN, CMD, ENTRYPOINT, COPY komutlarının çalışağı klasörü belirtir.
   
6. HEALTHCHECK :

- HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost/ || exit 1

7. SHELL: 



SHELL ["executable", "parameters"]

The SHELL instruction allows the default shell used for the shell form of commands to be overridden. The default shell on Linux is ["/bin/sh", "-c"], and on Windows is ["cmd", "/S", "/C"]. The SHELL instruction must be written in JSON form in a Dockerfile.

The SHELL instruction is particularly useful on Windows where there are two commonly used and quite different native shells: cmd and powershell, as well as alternate shells available including sh.

The SHELL instruction can appear multiple times. Each SHELL instruction overrides all previous SHELL instructions, and affects all subsequent instructions. For example:




``` docker
FROM microsoft/windowsservercore

# Executed as cmd /S /C echo default
RUN echo default

# Executed as cmd /S /C powershell -command Write-Host default
RUN powershell -command Write-Host default

# Executed as powershell -command Write-Host hello
SHELL ["powershell", "-command"]
RUN Write-Host hello

# Executed as cmd /S /C echo hello
SHELL ["cmd", "/S", "/C"]
RUN echo hello
```

8. STOPSIGNAL:

STOPSIGNAL signal

The STOPSIGNAL instruction sets the system call signal that will be sent to the container to exit. This signal can be a valid unsigned number that matches a position in the kernel’s syscall table, for instance 9, or a signal name in the format SIGNAME, for instance SIGKILL.

9. ONBUILD:

An ONBUILD command executes after the current Dockerfile build completes. ONBUILD executes in any child image derived FROM the current image. Think of the ONBUILD command as an instruction the parent Dockerfile gives to the child Dockerfile.

A Docker build executes ONBUILD commands before any command in a child Dockerfile.

ONBUILD is useful for images that are going to be built FROM a given image. For example, you would use ONBUILD for a language stack image that builds arbitrary user software written in that language within the Dockerfile, as you can see in Ruby’s ONBUILD variants.

10. ENV

To make new software easier to run, you can use ENV to update the PATH environment variable for the software your container installs. For example, ENV PATH /usr/local/nginx/bin:$PATH ensures that CMD ["nginx"] just works.

The ENV instruction is also useful for providing required environment variables specific to services you wish to containerize, such as Postgres’s PGDATA.

Lastly, ENV can also be used to set commonly used version numbers so that version bumps are easier to maintain, as seen in the following example:

```docker
ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3.4
RUN curl -SL http://example.com/postgres-$PG_VERSION.tar.xz | tar -xJC /usr/src/postgress && …
ENV PATH /usr/local/postgres-$PG_MAJOR/bin:$PATH
```

11. VOLUME

VOLUME ["/data"]

The VOLUME instruction creates a mount point with the specified name and marks it as holding externally mounted volumes from native host or other containers. The value can be a JSON array, VOLUME ["/var/log/"], or a plain string with multiple arguments, such as VOLUME /var/log or VOLUME /var/log /var/db. For more information/examples and mounting instructions via the Docker client, refer to Share Directories via Volumes documentation.

The docker run command initializes the newly created volume with any data that exists at the specified location within the base image. For example, consider the following Dockerfile snippet:

``` docker
FROM ubuntu
RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting
VOLUME /myvol
```

12. USER

If a service can run without privileges, use USER to change to a non-root user. Start by creating the user and group in the Dockerfile with something like RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres.

```
FROM microsoft/windowsservercore
# Create Windows user in the container
RUN net user /add patrick
# Set it for subsequent commands
USER patrick
```

### __Docker CLI__

https://docs.docker.com/engine/reference/commandline/build/

1. docker attach

Use docker attach to attach your terminal’s standard input, output, and error (or any combination of the three) to a running container using the container’s ID or name. This allows you to view its ongoing output or to control it interactively, as though the commands were running directly in your terminal.

To stop a container, use CTRL-c. This key sequence sends SIGKILL to the container. If --sig-proxy is true (the default),CTRL-c sends a SIGINT to the container. If the container was run with -i and -t, you can detach from a container and leave it running using the CTRL-p CTRL-q key sequence.

``` shell
$ docker run -d --name topdemo ubuntu /usr/bin/top -b

$ docker attach topdemo
```


2. docker build

The docker build command builds Docker images from a Dockerfile and a “context”. A build’s context is the set of files located in the specified PATH or URL. The build process can refer to any of the files in the context. For example, your build can use a COPY instruction to reference a file in the context.

The URL parameter can refer to three kinds of resources: Git repositories, pre-packaged tarball contexts and plain text files.

``` shell
docker build https://github.com/docker/rootfs.git#container:docker
```
diğer örnekler

```shell
$ docker build - < Dockerfile
With Powershell on Windows, you can run:

Get-Content Dockerfile | docker build -

```

opsiyonlar için: https://docs.docker.com/engine/reference/commandline/build/#options


3. docker commit
   
It can be useful to commit a container’s file changes or settings into a new image. This allows you to debug a container by running an interactive shell, or to export a working dataset to another server. Generally, it is better to use Dockerfiles to manage your images in a documented and maintainable way.

The --change option will apply Dockerfile instructions to the image that is created. Supported Dockerfile instructions: CMD|ENTRYPOINT|ENV|EXPOSE|LABEL|ONBUILD|USER|VOLUME|WORKDIR



``` shell

$ docker ps

CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS              NAMES
c3f279d17e0a        ubuntu:12.04        /bin/bash           7 days ago          Up 25 hours                            desperate_dubinsky
197387f1b436        ubuntu:12.04        /bin/bash           7 days ago          Up 25 hours                            focused_hamilton

$ docker commit c3f279d17e0a  svendowideit/testimage:version3

f5283438590d

$ docker images

REPOSITORY                        TAG                 ID                  CREATED             SIZE
svendowideit/testimage            version3            f5283438590d        16 seconds ago      335.7 MB

```

4. docker config

Manage Docker configs

``` shell
Command	Description
- docker config create	Create a config from a file or STDIN
- docker config inspect	Display detailed information on one or more configs
- docker config ls	List configs
- docker config rm	Remove one or more configs

```

5. docker container

https://docs.docker.com/engine/reference/commandline/container/#child-commands


ayrıca her birinin opsiyonları  da bulunmaktadır.

```
Child commands
Command                   Description
docker container  attach	Attach local standard input, output, and error streams to a running container
docker container commit   Create a new image from a container’s changes
docker container cp	      Copy files/folders between a container and the local filesystem
docker container create	  Create a new container
docker container diff	    Inspect changes to files or directories on a container’s filesystem
docker container exec	    Run a command in a running container
docker container export	  Export a container’s filesystem as a tar archive
docker container inspect	Display detailed information on one or more containers
docker container kill	    Kill one or more running containers
docker container logs	    Fetch the logs of a container
docker container ls	      List containers
docker container pause	  Pause all processes within one or more containers
docker container port	    List port mappings or a specific mapping for the container
docker container prune	  Remove all stopped containers
docker container rename	  Rename a container
docker container restart	Restart one or more containers
docker container rm	      Remove one or more containers
docker container run	    Run a command in a new container
docker container start	  Start one or more stopped containers
docker container stats	  Display a live stream of container(s) resource usage statistics
docker container stop	    Stop one or more running containers
docker container top	    Display the running processes of a container
docker container unpause	Unpause all processes within one or more containers
docker container update	  Update configuration of one or more containers
docker container wait	    Block until one or more containers stop, then print their exit codes
```
6. docker context

https://docs.docker.com/engine/context/working-with-contexts/

[Detail](0_architecture.md)

```
docker context create	  Create a context
docker context export	  Export a context to a tar or kubeconfig file
docker context import	  Import a context from a tar or zip file
docker context inspect	Display detailed information on one or more contexts
docker context ls	      List contexts
docker context rm	      Remove one or more contexts
docker context update	  Update a context
docker context use	    Set the current docker context
```


7. docker diff



List the changed files and directories in a container᾿s filesystem since the container was created. Three different types of change are tracked:

Symbol	Description
- A file or directory was added
- A file or directory was deleted
- A file or directory was changed

example

```

$ docker diff 1fdfd1f54c1b

C /dev
C /dev/console
C /dev/core
C /dev/stdout
C /dev/fd
C /dev/ptmx
C /dev/stderr
C /dev/stdin
C /run
A /run/nginx.pid
C /var/lib/nginx/tmp
A /var/lib/nginx/tmp/client_body
A /var/lib/nginx/tmp/fastcgi
A /var/lib/nginx/tmp/proxy
A /var/lib/nginx/tmp/scgi
A /var/lib/nginx/tmp/uwsgi
C /var/log/nginx
A /var/log/nginx/access.log
A /var/log/nginx/error.log

```


8. docker events

docker sisteminde meydana gelen tüm olaylar hakkında bilgi alınabilir. farklı componentler için farklı farklı eventler oluşcaktır. 


https://docs.docker.com/engine/reference/commandline/events/

Examples

``` shell

$ docker events --since 1483283804
2017-01-05T00:35:41.241772953+08:00 volume create testVol (driver=local)
2017-01-05T00:35:58.859401177+08:00 container create d9cd...4d70 (image=alpine:latest, name=test)
2017-01-05T00:36:04.703631903+08:00 network connect e2e1...29e2 (container=0fdb...ff37, name=bridge, type=bridge)
2017-01-05T00:36:04.795031609+08:00 container start 0fdb...ff37 (image=alpine:latest, name=test)
2017-01-05T00:36:09.830268747+08:00 container kill 0fdb...ff37 (image=alpine:latest, name=test, signal=15)
2017-01-05T00:36:09.840186338+08:00 container die 0fdb...ff37 (exitCode=143, image=alpine:latest, name=test)
2017-01-05T00:36:09.880113663+08:00 network disconnect e2e...29e2 (container=0fdb...ff37, name=bridge, type=bridge)
2017-01-05T00:36:09.890214053+08:00 container stop 0fdb...ff37 (image=alpine:latest, name=test)


$ docker events --filter 'event=stop'

2017-01-05T00:40:22.880175420+08:00 container stop 0fdb...ff37 (image=alpine:latest, name=test)
2017-01-05T00:41:17.888104182+08:00 container stop 2a8f...4e78 (image=alpine, name=kickass_brattain)

docker events --filter 'type=network'

2015-12-23T21:38:24.705709133Z network create 8b11...2c5b (name=test-event-network-local, type=bridge)
2015-12-23T21:38:25.119625123Z network connect 8b11...2c5b (name=test-event-network-local, container=b4be...c54e, type=bridge)

$ docker events --format '{{json .}}'

{"status":"create","id":"196016a57679bf42424484918746a9474cd905dd993c4d0f4..
{"status":"attach","id":"196016a57679bf42424484918746a9474cd905dd993c4d0f4..
{"Type":"network","Action":"connect","Actor":{"ID":"1b50a5bf755f6021dfa78e..
{"status":"start","id":"196016a57679bf42424484918746a9474cd905dd993c4d0f42..
{"status":"resize","id":"196016a57679bf42424484918746a9474cd905dd993c4d0f4..


```

9. docker export

Export a container’s filesystem as a tar archive

Examples

Each of these commands has the same result.

``` shell
$ docker export red_panda > latest.tar
$ docker export --output="latest.tar" red_panda
```

10. docker history

Show the history of an image

``` shell
$ docker history docker

IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
3e23a5875458        8 days ago          /bin/sh -c #(nop) ENV LC_ALL=C.UTF-8            0 B
8578938dd170        8 days ago          /bin/sh -c dpkg-reconfigure locales &&    loc   1.245 MB
be51b77efb42        8 days ago          /bin/sh -c apt-get update && apt-get install    338.3 MB
4b137612be55        6 weeks ago         /bin/sh -c #(nop) ADD jessie.tar.xz in /        121 MB
750d58736b4b        6 weeks ago         /bin/sh -c #(nop) MAINTAINER Tianon Gravi <ad   0 B
511136ea3c5a        9 months ago                                                        0 B                 Imported from -

```

11. docker image

manage ımages

https://docs.docker.com/engine/reference/commandline/image/#child-commands

```
Child commands
Command	Description
docker image build	  Build an image from a Dockerfile
docker image history	Show the history of an image
docker image import	  Import the contents from a tarball to create a filesystem image
docker image inspect	Display detailed information on one or more images
docker image load	    Load an image from a tar archive or STDIN
docker image ls	      List images
docker image prune	  Remove unused images
docker image pull	    Pull an image or a repository from a registry
docker image push	    Push an image or a repository to a registry
docker image rm	      Remove one or more images
docker image save	    Save one or more images to a tar archive (streamed to STDOUT by default)
docker image tag	    Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

```

12. docker kill

Kill one or more running containers

farklı kullanımları

``` shell
$ docker kill my_container
```

Send a custom signal to a container

The following example sends a SIGHUP signal to the container named my_container:

``` shell
$ docker kill --signal=SIGHUP  my_container
```
You can specify a custom signal either by name, or number. The SIG prefix is optional, so the following examples are equivalent:
``` shell
$ docker kill --signal=SIGHUP my_container
$ docker kill --signal=HUP my_container
$ docker kill --signal=1 my_container
```

13. doscker export/import/load/save


- save works with Docker images. It saves everything needed to build a container from scratch. Use this command if you want to share an image with others.
- load works with Docker images. Use this command if you want to run an image exported with save. Unlike pull, which requires connecting to a Docker registry, load can import from anywhere (e.g. a file system, URLs).
- export works with Docker containers, and it exports a snapshot of the container’s file system. Use this command if you want to share or back up the result of building an image.
- import works with the file system of an exported container, and it imports it as a Docker image. Use this command if you have an exported file system you want to explore or use as a layer for a new image.

https://pspdfkit.com/blog/2019/docker-import-export-vs-load-save/

14. docker logs

Fetch the logs of a container

Options

Name, shorthand	Default	Description
```
--details		Show extra details provided to logs
--follow , -f		Follow log output
--since		Show logs since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
--tail	all	Number of lines to show from the end of the logs
--timestamps , -t		Show timestamps
--until		API 1.35+
Show logs before a timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
```


```shell
$ docker run --name test -d busybox sh -c "while true; do $(echo date); sleep 1; done"
$ date
Tue 14 Nov 2017 16:40:00 CET
$ docker logs -f --until=2s
Tue 14 Nov 2017 16:40:00 CET
Tue 14 Nov 2017 16:40:01 CET
Tue 14 Nov 2017 16:40:02 CET
```

15. docker network

bu kısım zaetn detaylı bir şekilde ayrı bir md soyaında işleniyor.

[network](3_networ.md)

https://docs.docker.com/engine/reference/commandline/network/

16. docker plugin

Manage plugins.

Child commands

```
Command	              Description
docker plugin create	Create a plugin from a rootfs and configuration. Plugin data directory must contain config.json and rootfs directory.
docker plugin disable	Disable a plugin
docker plugin enable	Enable a plugin
docker plugin inspect	Display detailed information on one or more plugins
docker plugin install	Install a plugin
docker plugin ls	    List plugins
docker plugin push	  Push a plugin to a registry
docker plugin rm	    Remove one or more plugins
docker plugin set	    Change settings for a plugin
docker plugin upgrade	Upgrade an existing plugin

```

17. docker port

List port mappings or a specific mapping for the container


You can find out all the ports mapped by not specifying a PRIVATE_PORT, or just a specific mapping:

```shell
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                                            NAMES
b650456536c7        busybox:latest      top                 54 minutes ago      Up 54 minutes       0.0.0.0:1234->9876/tcp, 0.0.0.0:4321->7890/tcp   test
$ docker port test
7890/tcp -> 0.0.0.0:4321
9876/tcp -> 0.0.0.0:1234
$ docker port test 7890/tcp
0.0.0.0:4321
$ docker port test 7890/udp
2014/06/24 11:53:36 Error: No public port '7890/udp' published for test
$ docker port test 7890
0.0.0.0:4321

```

18. docker ps

List containers

Options
```
Name, shorthand	Default	Description

--all , -a		Show all containers (default shows just running)
--filter , -f		Filter output based on conditions provided
--format		Pretty-print containers using a Go template
--last , -n	-1	Show n last created containers (includes all states)
--latest , -l		Show the latest created container (includes all states)
--no-trunc		Don’t truncate output
--quiet , -q		Only display numeric IDs
--size , -s		Display total file sizes
```

19. docker pull

Pull an image or a repository from a registry

```shell
docker pull [OPTIONS] NAME[:TAG|@DIGEST]
```
docker hub dışında başka bir registery den almak için

```shell
docker pull myregistry.local:5000/testing/test-image
```

20. docker rename

```shell
docker rename my_container my_new_container
```
21. docker rm

remove docker container

```
docker rm $(docker ps -a -q)
```


Options
```
Name        shorthand	Default	Description
--force ,   -f		    Force the removal of a running container (uses SIGKILL)
--link ,    -l		    Remove the specified link
--volumes , -v        Remove anonymous volumes associated with the container
```

22. docker rmi

Remove one or more images

```
docker rmi [OPTIONS] IMAGE [IMAGE...]
```

23. docker secret

Manage Docker secrets

bu bölümle alakalı daha dtaylı bir döküman hazırlandı

https://docs.docker.com/engine/reference/commandline/secret/

[Detaylı Döküman](5_dockersecret.md)

24. docker stack

aslında swarm ortamının configurasyon üzerinden yönetlimesidir.

https://medium.com/devopsturkiye/docker-container-ve-swarm-mode-f6975717647e

https://docs.docker.com/engine/reference/commandline/stack/

25. docker system

Manage Docker

Child commands
```
Command	Description
docker system df	Show docker disk usage
docker system events	Get real time events from the server
docker system info	Display system-wide information
docker system prune	Remove unused data
```

```
$ docker system df

TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              5                   2                   16.43 MB            11.63 MB (70%)
Containers          2                   0                   212 B               212 B (100%)
Local Volumes       2                   1                   36 B                0 B (0%)

```
26. docker tag

Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE


Examples

Tag an image referenced by ID

To tag a local image with ID “0e5574283393” into the “fedora” repository with “version1.0”:
```
$ docker tag 0e5574283393 fedora/httpd:version1.0
```

Tag an image referenced by Name

To tag a local image with name “httpd” into the “fedora” repository with “version1.0”:
```
$ docker tag httpd fedora/httpd:version1.0
```

Note that since the tag name is not specified, the alias is created for an existing local version httpd:latest.

Tag an image referenced by Name and Tag

To tag a local image with name “httpd” and tag “test” into the “fedora” repository with “version1.0.test”:
```
$ docker tag httpd:test fedora/httpd:version1.0.test
****
```
Tag an image for a private repository
To push an image to a private registry and not the central Docker registry you must tag it with the registry hostname and port (if needed).
```
$ docker tag 0e5574283393 myregistryhost:5000/fedora/httpd:version1.0
```
27. docker top

Display the running processes of a container

28. docker trust

docker contex in uzak sunuculara giderken/gelirken güvenli olarka trasfer edilmesini sağlar. context imzalanır ve karşı taraf açar.

29. docker update

Update configuration of one or more containers

Warning: The docker update and docker container update commands are not supported for Windows containers.

Update a container’s cpu-shares

To limit a container’s cpu-shares to 512, first identify the container name or ID. You can use docker ps to find these values. You can also use the ID returned from the docker run command. Then, do the following:

```
$ docker update --cpu-shares 512 abebf7571666
```
Update a container with cpu-shares and memory
To update multiple resource configurations for multiple containers:

```
$ docker update --cpu-shares 512 -m 300M abebf7571666 hopeful_morse
```
Update a container’s kernel memory constraints
You can update a container’s kernel memory limit using the --kernel-memory option. On kernel version older than 4.6, this option can be updated on a running container only if the container was started with --kernel-memory. If the container was started without --kernel-memory you need to stop the container before updating kernel memory.

For example, if you started a container with this command:

```
$ docker run -dit --name test --kernel-memory 50M ubuntu bash
```
30. docker wait

Block until one or more containers stop, then print their exit codes

Examples

Start a container in the background.
```
$ docker run -dit --name=my_container ubuntu bash
```
Run docker wait, which should block until the container exits.

```
$ docker wait my_container
```

In another terminal, stop the first container. The docker wait command above returns the exit code.

```
$ docker stop my_container
```

This is the same docker wait command from above, but it now exits, returning 0.

```
$ docker wait my_container
0
```






### __Docker Compose File__

1. CONTEXT: Either a path to a directory containing a Dockerfile, or a url to a git repository.

```
build:
  context: ./dir 
```

2. BUILD: bahsi geçe servisin hangi dockerfile a göre build edileceğini belirtir.

```
build:
    context: ./MyWebApp
    dockerfile: Dockerfile-MyWebApp
```

3. DOCKERFILE:  Alternate Dockerfile. Compose uses an alternate file to build with. A build path must also be specified.

``` docker
build:
  context: .
  dockerfile: Dockerfile-alternate

```
4. ARGS: Add build arguments, which are environment variables accessible only during the build process.

First, specify the arguments in your Dockerfile:

``` docker
ARG buildno
ARG gitcommithash

RUN echo "Build number: $buildno"
RUN echo "Based on commit: $gitcommithash"
```

Then specify the arguments under the build key. You can pass a mapping or a list:

``` docker
build:
  context: .
  args:
    buildno: 1
    gitcommithash: cdc3b19
build:
  context: .
  args:
    - buildno=1
    - gitcommithash=cdc3b19
```
5. CONTAINER_NAME: normarlde contianer isimleri otomatik atanız ancak bazen container adına compose içinde ihtiyaç olabilir. örneğin ABC containerının oluşturduğu dosyaların başka bir container a kopyalmamösı gerekebilir budurmda container adı lazım olcaktır.

6. DEPENDS_ON: bir servis başka bir servise bağımlıysa o servisin öncelikle çalışması sağlanmalıdır.

```docker
version: '2'

services:
   nginx-service:
      build: WebSite
      depends_on:
      - ruby-service

   ruby-service:
      build: WebApp
      depends_on:
      - redis-service
    
   redis-service:
      image: redis

```

7. ENVIRONMENT

servislere (dockerfile) aktarılacak env değişkelerine buradan da tanımlama yapılabilir.

``` docker
environment:
    - MODE=PROD
    - DEBUG=true
    - PASSWORD=secret
```

8. IMAGE: servislerin oluşturacağı image ları belirler.

Eğer dockerfile belirtildiyse oradan bild alınan image verilen image tag ı ile taglanir.

```docker
image: myapp:1.0
build:
    context: ./WebAppFolder
    dockerfile: myapp_dockerfile
```

9. NETWORKS: Containerların dahil olcağı networkü belirtir.

```docker
services:
  some-service:
    networks:
     - some-network
     - other-network
```

10. VOLUMES: Containerlara volume ayarlamk için kulanılır.  host üzerindeki bir folder bağlanabilir, container üzerinde bir volume yaratılabilir ve son olarak volume konfigürayonbndaki bir volume containerda kullanılabilir.


``` docker

version: "3.8"
services:
  web:
    image: nginx:alpine
    volumes:
      - type: volume
        source: mydata
        target: /data
        volume:
          nocopy: true
      - type: bind
        source: ./static
        target: /opt/app/static

  db:
    image: postgres:latest
    volumes:
      - "/var/run/postgres/postgres.sock:/var/run/postgres/postgres.sock"
      - "dbdata:/var/lib/postgresql/data"

volumes:
  mydata:
  dbdata:

```

diğer örnek, short syntax

``` docker
volumes:
  # Just specify a path and let the Engine create a volume
  - /var/lib/mysql

  # Specify an absolute path mapping
  - /opt/data:/var/lib/mysql

  # Path on the host, relative to the Compose file
  - ./cache:/tmp/cache

  # User-relative path
  - ~/configs:/etc/configs/:ro

  # Named volume
  - datavolume:/var/lib/mysql

```
long syntax

``` docker
version: "3.8"
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - type: volume
        source: mydata
        target: /data
        volume:
          nocopy: true
      - type: bind
        source: ./static
        target: /opt/app/static

networks:
  webnet:

volumes:
  mydata:

```






### __Docker Compose CLI__

https://docs.docker.com/compose/reference/overview/

