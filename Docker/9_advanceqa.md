### Run Your App in Production

https://docs.docker.com/get-started/orchestration/

iki bölüm  var 

- Set up and use a Kubernetes environment on your development machine
- Set up and use a Swarm environment on your development machine

https://docs.docker.com/config/daemon/prometheus/


https://docs.docker.com/config/containers/start-containers-automatically/

- security
- logging
- scaling
- entend


### Device lara erişim

örnek usb

https://docs.sevenbridges.com/docs/mount-a-usb-drive-in-a-docker-container
```
docker run -t -i --device=/dev/ttyUSB0 ubuntu bash

Alternatively, assuming your USB device is available with drivers working, etc. on the host in /dev/bus/usb, you can mount this in the container using privileged mode and the volumes option. For example:

```
docker run -t -i --privileged -v /dev/bus/usb:/dev/bus/usb ubuntu bash
```



### Isolate containers with a user namespace

https://docs.docker.com/engine/security/userns-remap/



### Adding cusotm metadata to objects

__Docker Object Labels__

Labels are a mechanism for applying metadata to Docker objects, including:
- Images
- Containers
- Local daemons
- Volumes
- Networks
- Swarm nodes
- Swarm services


label ları tag gibi de düşünebiliriz. obljlerimizi tanımlamaya yarar filtrelem yaparken label lardan yararlanaılabilir. hata bulmaya çalışırke faydalı olabilir.

detaylaı için : https://docs.docker.com/config/labels-custom-metadata/



- https://gokhansengun.com/docker-ipuclari-soru-ve-cevaplar-bolum-1/
- https://gokhansengun.com/docker-ipuclari-soru-ve-cevaplar-bolum-2/
- https://gokhansengun.com/docker-ipuclari-soru-ve-cevaplar-bolum-3/
- https://gokhansengun.com/docker-ipuclari-soru-ve-cevaplar-bolum-4/










