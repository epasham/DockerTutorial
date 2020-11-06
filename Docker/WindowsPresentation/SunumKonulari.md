1. dockerfile
   örnekler

- https://github.com/muratcabuk/dotnet-docker
- https://github.com/dockersamples/example-voting-app


docker file yazmak

- https://github.com/dotnet/dotnet-docker



2. image registery
docker hub
azure container registery
https://cloud.google.com/container-registry
https://aws.amazon.com/ecr/
https://help.sonatype.com/repomanager3


docker service create --name mynginx --replicas=3 -p 8088:80 --network myoverlay yamackurtulus/nginx-windows:1.15-servercore1809

 docker service create --name mynginx --replicas=3 -p 8088:80 --network my-ingress mcr.microsoft.com/dotnet/core/samples:aspnetapp-nanoserver-1809
 
 
 
 docker service create --name swarmtest --replicas=2 -p 8090:80  swarmtest.azurecr.io/muratcabukdotnetdocker:v1.2.1 
 
swarmtest.azurecr.io/muratcabukdotnetdocker:v1.2.1
 
 


3. Jenkins kurulumu

- docker run -p 8080:8080 -p 8081:8081  yamackurtulus/jenkins-windows

4. nginx kurulumu

- docker run -p 8084:80 yamackurtulus/nginx-windows:1.15-servercore1809


5. baştan sona örnek





 - https://github.com/yamac-kurtulus/Windows-Docker-Images

 - https://hub.docker.com/u/yamackurtulus
 
 
 
 grafana port: 3000
 portainer port: 9000
 
 
