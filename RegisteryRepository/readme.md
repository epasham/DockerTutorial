registery lere login olmada key save lernirken bir hata meydana geliyor 

```
Error saving credentials: error storing credentials - err: exit status 1, out: `Cannot autolaunch D-Bus without X11 $DISPLAY`
```

buu hatyı gidermek için alttaki komutu çalıştırınız.

```
apt install gnupg2 pass
```

eğer bu yöntem çalışmazsa 

stackoverflow da ki soruyu takip edebilirsiniz

https://stackoverflow.com/questions/50151833/cannot-login-to-docker-account


https://hasanyousuf.com/2019/09/21/how-to-install-sonatype-nexus-3-on-centos6-10/
https://qiita.com/leechungkyu/items/86cad0396cf95b3b6973
https://medium.com/@acokgungordu/nexus-repository-manager-3%C3%BC-depo-olarak-kullanma-docker-images-71ef1b2ccdea
https://medium.com/@acokgungordu/nexus-repository-manager-3%C3%BC-depo-olarak-kullanma-docker-images-71ef1b2ccdea

benim tavsiyem nexus 3 ü docker üzerinden kurmak. pull ettikten sonra run ederken default 8081 den 8090 a kadar portlat expose eilirse iyi olur.

8081 web sitesi için açılan herbir repository için port ataması yapmak lazım. 

docker da http ile registery yapılmak isteniyorsa insecure regitery yapıması lazım öncelikle

https://docs.docker.com/registry/insecure/

/etc/docker/daemon.json doyası create edilip (eğer değilse) alttaki bölüm eklnemeli

```
{
  "insecure-registries" : ["myregistrydomain.com:5000"]
}
```



https://docs.docker.com/engine/reference/commandline/push/

```

$ docker tag rhel-httpd:12.03 registry-host:5000/myadmin/rhel-httpd:12.04

$ docker push registry-host:5000/myadmin/rhel-httpd:12.04
```