# Docker Tutorial


## Docker CE vs EE

Docker Community Edition (CE) is the new name for the free Docker products. Docker CE runs on Mac and Windows 10, on AWS and Azure, and on CentOS, Debian, Fedora, and Ubuntu and is available from Docker Store. Docker CE includes the full Docker platform and is great for developers and DIY ops teams starting to build container apps.


https://blog.docker.com/2017/03/docker-enterprise-edition/

https://nickjanetakis.com/blog/docker-community-edition-vs-enterprise-edition-and-their-release-cycle

## Install Docker CE (Ubuntu)

### Install using the repository

https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce

1. Update the apt package index:
    $ sudo apt-get update

2. Install packages to allow apt to use a repository over HTTPS:
  $ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    
3. Add Docker’s official GPG key:

  $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  
Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.

  sudo apt-key fingerprint 0EBFCD88
  
4. Use the following command to set up the stable repository. You always need the stable repository, even if you want to install builds from the edge or test repositories as well. To add the edge or test repository, add the word edge or test (or both) after the word stable in the commands below.

for x86_64 / amd64

  $ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
### install Docker CE

1. Update the apt package index.

  $ sudo apt-get update
  
2. Install the latest version of Docker CE, or go to the next step to install a specific version:

  $ sudo apt-get install docker-ce
  
3. Verify that Docker CE is installed correctly by running the hello-world image.

  $ sudo docker run hello-world
   
### Upgrade Docker CE

  $ sudo apt-get update
  $ sudo apt-get install docker-ce
  
