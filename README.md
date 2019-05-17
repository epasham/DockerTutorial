# Docker Tutorial




## Management Commands:
  - builder:     Manage builds
  - config:      Manage Docker configs
  - container:   Manage containers
  - engine:      Manage the docker engine
  - image:       Manage images
  - network:     Manage networks
  - node:        Manage Swarm nodes
  - plugin:      Manage plugins
  - secret:      Manage Docker secrets
  - service:     Manage services
  - stack:       Manage Docker stacks
  - swarm:       Manage Swarm
  - system:      Manage Docker
  - trust:       Manage trust on Docker images
  - volume:      Manage volumes

## Commands:
  - attach:      Attach local standard input, output, and error streams to a running container
  - build:       Build an image from a Dockerfile
  - commit:      Create a new image from a container's changes
  - cp:          Copy files/folders between a container and the local filesystem
  - create:      Create a new container
  - deploy:      Deploy a new stack or update an existing stack
  - diff:        Inspect changes to files or directories on a container's filesystem
  - events:      Get real time events from the server
  - exec:        Run a command in a running container
  - export:      Export a container's filesystem as a tar archive
  - history:     Show the history of an image
  - images:      List images
  - import:      Import the contents from a tarball to create a filesystem image
  - info:        Display system-wide information
  - inspect:     Return low-level information on Docker objects
  - kill:        Kill one or more running containers
  - load:        Load an image from a tar archive or STDIN
  - login:       Log in to a Docker registry
  - logout:      Log out from a Docker registry
  - logs:        Fetch the logs of a container
  - pause:       Pause all processes within one or more containers
  - port:        List port mappings or a specific mapping for the container
  - ps:          List containers
  - pull:        Pull an image or a repository from a registry
  - push:        Push an image or a repository to a registry
  - rename:      Rename a container
  - restart:     Restart one or more containers
  - rm:          Remove one or more containers
  - rmi:         Remove one or more images
  - run:         Run a command in a new container
  - save:        Save one or more images to a tar archive (streamed to STDOUT by default)
  - search:      Search the Docker Hub for images
  - start:       Start one or more stopped containers
  - stats:       Display a live stream of container(s) resource usage statistics
  - stop:        Stop one or more running containers
  - tag:         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  - top:         Display the running processes of a container
  - unpause:     Unpause all processes within one or more containers
  - update:      Update configuration of one or more containers
  - version:     Show the Docker version information
  - wait:        Block until one or more containers stop, then print their exit codes











### Türkçe kaynaklar

Gökhan Şengün Yazı Dizisi

- https://gokhansengun.com/docker-nedir-nasil-calisir-nerede-kullanilir/

- https://gokhansengun.com/docker-yeni-image-hazirlama/

- https://gokhansengun.com/docker-compose-nasil-kullanilir/

- http://www.netas.com.tr/blog/docker-bolum-1-nedir-nasil-calisir-nerede-kullanilir/


https://www.xenonstack.com/blog/devops/docker-application-architecture-hub-images/amp/

https://docs.docker.com/v17.09/engine/userguide/storagedriver/imagesandcontainers/#the-copy-on-write-cow-strategy

https://stackoverflow.com/questions/19234831/where-are-docker-images-stored-on-the-host-machine

https://docs.docker.com/storage/#more-details-about-mount-types

https://www.digitalocean.com/community/tutorials/the-docker-ecosystem-an-introduction-to-common-components#top


### Docker Cheat Sheet

https://github.com/wsargent/docker-cheat-sheet


### Source
https://docs.docker.com/v17.09/engine/installation/

Docker: Packaging your apps to deploy and run anywhere
Docker is an open platform that enables developers and administrators to build [images](https://docs.docker.com/glossary/?term=image), ship, and run distributed applications in a loosely isolated environment called a [container](https://www.docker.com/what-container). This approach enables efficient application lifecycle management between development, QA, and production environments.

The [Docker platform](https://docs.docker.com/engine/docker-overview/#the-docker-platform) uses the [Docker Engine](https://docs.docker.com/engine/docker-overview/#docker-engine) to quickly build and package apps as [Docker images](https://docs.docker.com/glossary/?term=image) created using files written in the [Dockerfile](https://docs.docker.com/glossary/?term=Dockerfile) format that then is deployed and run in a [layered container](https://docs.docker.com/engine/userguide/storagedriver/imagesandcontainers/#container-and-layers).

You can either create your own layered images as dockerfiles or use existing ones from a registry, like Docker Hub.

The [relationship between Docker containers, images, and registries](https://docs.microsoft.com/en-us/dotnet/standard/microservices-architecture/container-docker-introduction/docker-containers-images-registries) is an important concept when architecting and building containerized applications or microservices. This approach greatly shortens the time between development and deployment.


Source : [Introduction to .NET and Docker](https://docs.microsoft.com/en-us/dotnet/core/docker/intro-net-docker)




## Docker CE vs EE

Docker Community Edition (CE) is the new name for the free Docker products. Docker CE runs on Mac and Windows 10, on AWS and Azure, and on CentOS, Debian, Fedora, and Ubuntu and is available from Docker Store. Docker CE includes the full Docker platform and is great for developers and DIY ops teams starting to build container apps.


https://blog.docker.com/2017/03/docker-enterprise-edition/

https://nickjanetakis.com/blog/docker-community-edition-vs-enterprise-edition-and-their-release-cycle

## Install Docker CE (Ubuntu)

### Install using the repository

https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce

1. Update the apt package index:
```
$ sudo apt-get update
```

2. Install packages to allow apt to use a repository over HTTPS:
  
```
  $ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```
    
3. Add Docker’s official GPG key:

```
  $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  
```
  
Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.

```
  sudo apt-key fingerprint 0EBFCD88
```
  
4. Use the following command to set up the stable repository. You always need the stable repository, even if you want to install builds from the edge or test repositories as well. To add the edge or test repository, add the word edge or test (or both) after the word stable in the commands below.

for x86_64 / amd64

```
  $ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```
   
### install Docker CE

1. Update the apt package index.
```
  $ sudo apt-get update
```
  
2. Install the latest version of Docker CE, or go to the next step to install a specific version:

```
  $ sudo apt-get install docker-ce
```
  
3. Verify that Docker CE is installed correctly by running the hello-world image.
```
  $ sudo docker run hello-world
```
   
### Upgrade Docker CE
```
  $ sudo apt-get update
  $ sudo apt-get install docker-ce

  ```
  
<<<<<<< HEAD


## Docker Images from Docker Hub


Download and run nginx image

```
docker run -p 8080:80 nginx
```
-p routes 8080 host port to 80 container port


Download ubuntu latest version
 
 ```
 docker pull ubuntu
 ```
 and run it

 ```
 docker run -it ubuntu
 ```

see running containers and its status

```
sudo docker ps
```

stop running container

```
sudo docker stop <containerid>
```

=======
###  List Docker images and List Docker containers (running, all, all in quiet mode)

```
docker image ls

docker container ls
docker container ls --all
docker container ls -aq
```  

### copy docker image to another host

First save the docker image to a zip file

```
docker save <docker image name> | gzip > <docker image name>.tar.gz
```
Then load the exported image to docker using the below command
```
zcat <docker image name>.tar.gz | docker load
```
docker export - saves a container’s running or paused instance to a file
docker save - saves a non-running container image to a file

### duplicate runnig container 


create a new image from that container using the docker commit command
```
docker commit c5a24953e383 newimagename
```
and then run the container

```
docker run [...same arguments as the other one...] newimagename
```
  

### Swarm vs Compose vs Network

Bir proje için aşağıdaki işlemlerin yapılcağını varsayalım

- 10 makinamızın olduğunu ve bunları yapılacak projede container larımını barındırmak için kullanacağız. (Swarm)

- Projemiz için web, app ve db katmanlarını bu yapı üzerinde ayağa kaldıracağız. (Compose)

- ve bu 3 katmanı bir biriyle haberleştireceğiz. (Network)


##### Swarm
Containerların organizasyonu ile ilgilenir. hangi makinada (host da) hangi container olacak hangi container ne iş yapacak. ayrıca bu node ları cluster olarak aylarlabilir. Orchestration san farklı bir olaydır. 


##### Compose
farklı hostlarda bulunan containerların grup olarak çalışmasını sağlar. farklı vontainer ların bir servisi sunmasını sağlar.

[Türkçe link](http://devnot.com/2017/docker-compose/), [Türkçe link](http://ilkinulas.github.io/development/test/junit/docker/2018/03/11/docker-ve-docker-compose.html)


##### Network
cotainerların iletişimini sağlar.

  
  
### Load Balancing

#### Docker Swarm

https://www.nginx.com/blog/docker-swarm-load-balancing-nginx-plus/


## Context

### [Create your container](https://github.com/muratcabuk/DockerTutorial/blob/master/CreateYourDockerImage.md)

### [Dockerize .NET Core Application](https://github.com/muratcabuk/DockerTutorial/blob/master/DockerizeNETCoreApp.MD)

>>>>>>> 19e780844cb31c72eab7a9367d43144af98e6e83


## Useful Commands

get running container : 

```
sudo docker ps
```
get running container detail : 

```
sudo docker exec -it (container name) ip addr

sudo docker exec -it <container-id> /bin/bash
```


login running container : 
```
sudo docker exec -it (container name) sh
```

start containers
```
docker start $(docker ps -a -q --filter "status=exited") (filter parameter can be changed)
```
stop all containers
```
docker stop $(docker ps -a -q)
```
remove all containers 
```
docker rm $(docker ps -a -q)
```



