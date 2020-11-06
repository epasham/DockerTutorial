




https://docs.microsoft.com/en-us/virtualization/community/team-blog/2017/20170419-use-nginx-to-load-balance-across-your-docker-swarm-cluster


https://github.com/dockersamples/aspnet-monitoring


https://github.com/bxtp4p/docker-logging-win


https://hub.docker.com/_/microsoft-dotnet-framework-samples/


https://github.com/microsoft/dotnet-framework-docker/tree/master/samples/aspnetapp



https://hub.docker.com/_/microsoft-windows-base-os-images



https://blog.sixeyed.com/dockerizing-nerd-dinner-part-1-running-a-legacy-asp-net-app-in-a-windows-container/


https://blog.sixeyed.com/dockerizing-nerd-dinner-part-2-connecting-asp-net-to-sql-server/


https://hub.docker.com/_/microsoft-dotnet-core-samples/



### Temel Komutlar
- docker swarm hakkında bilgi almak için

```
$ docker info 
```


- node ları manager yapmak için

```
$ docker node promote nodeadi
```

- docker node hakkıdan detaylı bilgi almak için

```
$ docker inspect nodeadi
```



### portainer kurulumu

önce herhangi bir makinaya portainer kurlur daha sonra yine herhangi makinaya bir agent kurularak adresi portainer a girilir. biz ikisini de aynı makinaya kuruyoruz

eğer sisteme samba üzerinden paylaşım yaparak volume belirtmek istiyorsak alttaki komut mount eder. tabi öncelikl enode lardan birinde share etmiş olmamaız lazım

```
New-SmbGlobalMapping -RemotePath \\node3\SharedFolder  -LocalPath L: -Persistent $true -Credential (Get-Credential) -RequirePrivacy $true
```
daha sonra kuruyoruz.



```
docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart always -v \\.\pipe\docker_engine:\\.\pipe\docker_engine -v L:\Portainer\data:C:\data' portainer/portainer-ce

```
direk kurmak istiyorsak


```
docker volume create portainer_data

docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart always -v \\.\pipe\docker_engine:\\.\pipe\docker_engine -v portainer_data:C:\data portainer/portainer-ce

```


daha sonra alttaki komutla agent kuruyoruz
```
docker run -d -p 9001:9001 --name portainer_agent --restart=always -v \\.\pipe\docker_engine:\\.\pipe\docker_engine portainer/agent

```

- swarm kurulumunda ise docker stack kullanılıyor.

```
$ curl https://downloads.portainer.io/portainer_windows_stack.yml -o portainer_windows_stack.yml
$ docker stack deploy --compose-file=portainer_windows_stack.yml portainer

```


### Overlay Network
- overlay network oluşturmak için

dikkat sakın windows üzerinde encrypted network oluşturma desteklenmiyot.


**winsows overlay** 


- https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/swarm-mode

- https://stackoverflow.com/questions/45841135/docker-stack-deploy-unable-to-set-dnsrr-as-ports-are-exposed-as-ingress

- https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/swarm-mode#deploying-services-to-a-swarm



```
docker network create --driver overlay --ingress --attachable --subnet=10.11.0.0/16 --gateway=10.11.0.2 my-ingress
```


- https://docs.microsoft.com/en-us/virtualization/windowscontainers/container-networking/network-drivers-topologies


```
docker network create --driver overlay --attachable --subnet 192.168.0.0/24 --gateway 192.168.0.1 myoverlay
```



- default overlay (ingress) network kullanararak container çalıştırma

```
docker run -it --rm  -d -p 8000:80 --name aspnetcore_sample mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809



docker run -it --rm  -d -p 8006:80 --name aspnetcore_sample1 mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809
docker run -it --rm  -d -p 8007:80 --name aspnetcore_sample2 mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809
docker run -it --rm  -d -p 8008:80 --name aspnetcore_sample3 mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809
docker run -it --rm  -d -p 8009:80 --name aspnetcore_sample4 mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809
docker run -it --rm  -d -p 8010:80 --name aspnetcore_sample5 mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809
docker run -it --rm  -d -p 8011:80 --name aspnetcore_sample6 mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809
```


windows local image ı direkt kullanamıyor bu nedenle bi registery ye koymak gerekiyor.

```
docker run -it --rm  -d -p 8012:80 --name aspnetcore_sample7 muratcabuk/aspnetcore:winnanoserver-1809
```


- overlay network belirterek çalıştırma

```
docker service create --name myaspnetapp mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809 --network myoverleynetwork --publish 80:80 --hostname myaspnetapp --replicas 3

docker service create --name testwebapp mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809 --mode global --network overleynetwork --publish 8003:80 --hostname myaspnetapp --replicas 3

curl 
docker service create --name myaspnetapp -p 8002:80 mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809


docker service create --name testapp -p published=8005,target=80,mode=host --endpoint-mode dnsrr --mode global --network testoverlay3  muratcabuk/aspnetcore:winnanoserver-1809

docker service create --name myaspnetapp2 -p 8003:80 --network testoverlay mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809

```




### Prometheus kurulumu

windows da yapılmış bir çok uygulamnın image ını alttaki adreten bulabilirsiniz

 - https://github.com/yamac-kurtulus/Windows-Docker-Images

 - https://hub.docker.com/u/yamackurtulus

 
 
```
Consul
DotnetCore Selenium With Chrome
Grafana
IIS-ReverseProxy
Jaeger
Jenkins
Loki
Nexus
Node
PostgreSQL
Prometheus
Rabbitmq
Redis
Seq
Zipkin
last month
mssql-prometheus-exporter
nginx 

```
 
 
 
 



**prometheus**


öncelikle prometeus için docker daemon metrikleri paylaşabilmei ayarlar yapıldı

yapılan ayarlar : https://docs.docker.com/config/daemon/prometheus/

daha sonra image container çalıştırıldı. bu image da zaten gerekli tüm yarlar yapılmış.

```
docker run -p 9090:9090 --restart always  -d  yamackurtulus/prometheus-windows:2.20.0-nanoserver1809
```


- https://docs.docker.com/config/daemon/prometheus/

- https://prometheus.io/docs/guides/dockerswarm/

- https://prometheus.io/docs/prometheus/latest/installation/

- https://github.com/yamac-kurtulus/Windows-Docker-Images



**prometheus örnek Promql leri**

- https://gist.github.com/eeddaann/7e35141782beb9b948eaf44aebd993eb
- https://www.weave.works/blog/swarmprom-prometheus-monitoring-for-docker-swarm
- https://prometheus.io/docs/prometheus/latest/querying/examples/
- https://dzone.com/articles/swarmprom-prometheus-monitoring-for-docker-swarm 
 
 
 

### Grafana Kurulumu

ini dosyası zaten image içinde ayarlanmış ayar yapmaya geek kalmadı. ancak gerek olsaydı tek şansımız image ıtekrar build etemek. çünki windows dosya bind etmeye izin vermyor bu durunda sadece tek dosyayı ezemşyoruz. ancak bütün bir klasörde ezilebilir tabii ki.

açtıktan sonra prometheus linkini girmek gerekiyor. Veri kaynağı olarak kullanılabilmesi için.

```
docker run -p 3000:3000 --restart always  -itd  yamackurtulus/grafana-windows:nanoserver-1809 
```



task üzerinden log okumak için

docker logs $(docker inspect --format "{{.Status.ContainerStatus.ContainerID}}" <task_id>)
