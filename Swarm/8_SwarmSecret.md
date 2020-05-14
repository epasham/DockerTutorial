https://docs.docker.com/engine/swarm/secrets/

https://docs.docker.com/engine/swarm/secrets/

https://docs.docker.com/engine/swarm/configs/


iki sistem var biri config biri secret

oluşturduğumuz bu iki sistemde aslında container a bir path olarak bağlanıyor. örneğin secret /run/secrets/xxxx_secret_name gibi bir path kullanıyor


mesela postgre image  ıpassword okumak için iki yöntem sunuyor ENV variable olrak biri değeri direkt girmek diğeri ise bir dosynın path ini girmak şeklinde. eğer secret i bir txt doyaına yazıp şifrelersek ve bunu da progre image ına env olarak bağlarsa dosyadan okuyabilir. ve bu container kapandığı an dosya uçacağı için güvenli bir key oluşturulmuş olutruz.

```
docker secret create psql_user psql_user.txt

echo "mypassword" | docker secret create psql_pas -

docker service create --name psql --secret psql_user -- secret psql_pass \ 
     -e PSTGRES_PASSWORD_FILE=/run/secrets/psql_pass -e PSTGRES_USER_FILE=/run/secrets/psql_user postgres

işlem bittikten sonra servisi çalıştırp exec komutu ile ilgili patha gidip dosyaya bakarsak veririni orada yazıı olduğunu görmüş oluruz.

```

#### Config

config ram disk kullanmaz, nonsesitive bilgiler için uyundur, encryp değildir ve diek container a bağlanır.

kulanımı 

```

$ echo "This is a config" | docker config create my-config -

$ docker service create --name redis --config my-config redis:alpine


$ docker ps --filter name=redis -q

5cb1c2348a59

$ docker container exec $(docker ps --filter name=redis -q) ls -l /my-config

-r--r--r--    1 root     root            12 Jun  5 20:49 my-config

$ docker container exec $(docker ps --filter name=redis -q) cat /my-config

This is a config

```
Try removing the config. The removal fails because the redis service is running and has access to the config.

```
$ docker config ls

ID                          NAME                CREATED             UPDATED
fzwcfuqjkvo5foqu7ts7ls578   hello               31 minutes ago      31 minutes ago


$ docker config rm my-config

Error response from daemon: rpc error: code = 3 desc = config 'my-config' is
in use by the following service: redis

```
Remove access to the config from the running redis service by updating the service.

```
$ docker service update --config-rm my-config redis
```
Repeat steps 3 and 4 again, verifying that the service no longer has access to the config. The container ID is different, because the service update command redeploys the service.

```

$ docker container exec -it $(docker ps --filter name=redis -q) cat /my-config

cat: can't open '/my-config': No such file or directory

```
Stop and remove the service, and remove the config from Docker.

```
$ docker service rm redis

$ docker config rm my-config

```

daha advance bir örnek için
https://docs.docker.com/engine/swarm/configs/#advanced-example-use-configs-with-a-nginx-service

#### secret

secret ise encryp olarak saklanır.

A node only has access to (encrypted) secrets if the node is a swarm manager or if it is running service tasks which have been granted access to the secret. When a container task stops running, the decrypted secrets shared to it are unmounted from the in-memory filesystem for that container and flushed from the node’s memory.

If a node loses connectivity to the swarm while it is running a task container with access to a secret, the task container still has access to its secrets, but cannot receive updates until the node reconnects to the swarm.

You can add or inspect an individual secret at any time, or list all secrets. You cannot remove a secret that a running service is using. See Rotate a secret for a way to remove a secret without disrupting running services.

To update or roll back secrets more easily, consider adding a version number or date to the secret name. This is made easier by the ability to control the mount point of the secret within a given container.

basit bir örnek

```
$ printf "This is a secret" | docker secret create my_secret_data -

$ docker service  create --name redis --secret my_secret_data redis:alpine

$ docker service ps redis

her şey ylundaysa üstteki  komut problemsiz çalışacaktır

```
secret verisini okumak için

```
$ docker ps --filter name=redis -q

5cb1c2348a59

$ docker container exec $(docker ps --filter name=redis -q) ls -l /run/secrets

total 4
-r--r--r--    1 root     root            17 Dec 13 22:48 my_secret_data

$ docker container exec $(docker ps --filter name=redis -q) cat /run/secrets/my_secret_data

This is a secret

```

secret i silmek için öncelikle container la olan bağını silmemiz gerekiyor.


```
Remove access to the secret from the running redis service by updating the service.

$ docker service update --secret-rm my_secret_data redis


```
herşey doğruysa aşağıdaki şekilde secret in silindiğinden emin oluruz


```

$ docker container exec -it $(docker ps --filter name=redis -q) cat /run/secrets/my_secret_data

cat: can't open '/run/secrets/my_secret_data': No such file or directory

```

Stop and remove the service, and remove the secret from Docker.
```
$ docker service rm redis

$ docker secret rm my_secret_data
```

https://docs.docker.com/engine/swarm/secrets/#intermediate-example-use-secrets-with-a-nginx-service


https://docs.docker.com/engine/swarm/secrets/#advanced-example-use-secrets-with-a-wordpress-service



### compose dosyasında kullanım



This example creates a simple WordPress site using two secrets in a compose file.

The keyword secrets: defines two secrets db_password: and db_root_password:.

When deploying, Docker creates these two secrets and populates them with the content from the file specified in the compose file.

The db service uses both secrets, and the wordpress is using one.

When you deploy, Docker mounts a file under /run/secrets/<secret_name> in the services. These files are never persisted in disk, but are managed in memory.


```
version: '3.1'

services:
   db:
     image: mysql:latest
     volumes:
       - db_data:/var/lib/mysql
     environment:
       MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD_FILE: /run/secrets/db_password
     secrets:
       - db_root_password
       - db_password

   wordpress:
     depends_on:
       - db
     image: wordpress:latest
     ports:
       - "8000:80"
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD_FILE: /run/secrets/db_password
     secrets:
       - db_password


secrets:
   db_password:
     file: db_password.txt
   db_root_password:
     file: db_root_password.txt

volumes:
    db_data:
```