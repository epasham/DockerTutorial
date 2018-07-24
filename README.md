# Docker Tutorial

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
  
  
### Load Balancing

#### Docker Swarm

https://www.nginx.com/blog/docker-swarm-load-balancing-nginx-plus/


## Context

### [Create your container] (https://github.com/muratcabuk/DockerTutorial/blob/master/CreateYourDockerImage.md)

### [Dockerize .NET Core Application](https://github.com/muratcabuk/DockerTutorial/blob/master/DockerizeNETCoreApp.MD)
  
  
  
  
