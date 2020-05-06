1. öncelikle 3 sunucununda hostname ile birbirlerini pingleyebildiğinden emin olmalıyız.

/etc/hosts dosyasına iligi malinların hostname ve iplerini birbirlerini görecek şekilde girmeliyiz.

2. daha sonra her 3 sunucuya da docker ı kuruyoruz.

3. her üç sunucudada kurulduğunu alttaki komutla test ettikten sonra 

sudo systemctl status docker

bütün sunucularda root olmadan docker komutşarını çağırabilmek için alttaki komutlşarı çalıştırmalıyız.

```
$ sudo usermod -aG docker ${USER}
$ su - ${USER}
$ id -nG
$ sudo usermod -aG docker muratcabuk
```

4. daha node lardan birinde alttaki komutu çalıştırıyoruz

```
docker swarm init
```

bu komut aslında bize tek node lu swarm oluşturmuş oldu. komut çalıştıktan sonra aşağıdakine benzer bir sonuççıkmış olmalı karşımıza.

burada dikkat edilirse diğer node ların bu node a dahil edilebilmesi için bir token üzeritilmiş. bu tken yardımıyla diğer node lar cluster a dahil edilebilir ancak bu token unutulursa öğrenmek için _docker swarm join-token worker_ komutu kullanılabilir.

```
Swarm initialized: current node (z8wyx624gcgocqouz3vl0q6g8) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-6730ztmwkta9se2hmhjo29myefiurkfdsc7n58cj22g950ckms-b53wkoyngz95xvmea63fqep16 10.0.0.5:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
bu aşamada bu node üzerinde docker network ls kmutunu çalıştırırsak alttaki gibi bir sonuç  görürüz

```
$ docker network ls

NETWORK ID          NAME                DRIVER              SCOPE
c852418ea069        bridge              bridge              local
a2cbd0d7a8eb        docker_gwbridge     bridge              local
d5b950a6542b        host                host                local
chncdp87jo3t        ingress             overlay             swarm
7a6bc28751e7        none                null                local
```
dikkat edilirse name i ingress olan overlay bi network oluştuğu görülür. detayları için [network](../Docker/3_network.md) bölümünü okuyunuz.


5. diğer sunucularda yukarıda elde ettiğimiz token la aşağıdaki komut çalıştırılır.

```
 docker swarm join --token SWMTKN-1-6730ztmwkta9se2hmhjo29myefiurkfdsc7n58cj22g950ckms-b53wkoyngz95xvmea63fqep16 10.0.0.5:2377
```

daha sonra il çalıştırmız manager nodda alttaki komutu çalıştırısak 3 node olduğunu görebiliriz

```
 docker node ls
```

