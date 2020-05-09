
### Deployment Intro

- docker swarm : bu komut ve alt option ları ile birlikte swarm nı kendisini yöntetiyoruz. yani node ları ve cluster ı
https://docs.docker.com/engine/reference/commandline/swarm/
- docker stack : swarm mod için container/larımızı ayağa kaldırıyoruz, durduyoruz vb . ancak unutmamalı burada amaç compose üzeridne birşeyler yapmak yani amaç bir grup servisi yöntemek ve bunları bit bütün lark yönetmek.
https://docs.docker.com/engine/reference/commandline/stack/
- docker service: burad amaç docker swarm üzerinde koşan her bir container ı tekil olarak yönetmek. swarm a geçtiğimizde artık docker container değil docker service konuşuyor oluyoruz. Artık tek bit container değil aynı işi yapan belki birden fazla replica container ı tek bir servis olark yönetiyoruz.
https://docs.docker.com/engine/reference/commandline/service_create/ 
- docker cluster: bu enterprise sürüm için kullanılıyor. docker cluster  ı oluşturmak ve yönetmek için. biz bunu swarm üzeriden yapıyoruz.



Öncelikle şunu bilmek gerekiyor dcoker compose un swarm la birilgisi yok. Biz docker-compose up dediğimizde aslında sadece bir veya birde fazla container ın ayağa kalmasını sağlamış oluyoruz. burada amaç cli da yapılan işleri configürasyon dosyasından yönetmek böylece cof managemet problemi çözülmüş oluyor.

Aynı anda birden fazla sunucuyu swarm modda ayağa kaldırmak için kullanıcak komut _docker stack deploy_. 

  ```
  docker stack deploy --compose-file docker-compose.yml
  ```

Docker stack ın compose dan farkları

- docker-compose python tabnlı iken docker stack go tabanlıdır
- docker-compose build alabilirken stack build alamaz (ancak bu konu çalışmlar var)
- dcoker-compose swarm için deploymen yapamazken stack yapabilmektedir.

ileride docker-compose un kaldırılacağı ve sadece stack kalacağı konuşuluyor.

peki swarm build alamıyorsa deployment ı build alınması gereken image lar için nasıl yapacak?

bunun için öncelikle _docker-compose push_ komutuyla image lar registery ye kaydedilir daha sonra _docker stack deploy_ ile swarm deployment ı yapılır.

detaylı örnek için : https://docs.docker.com/engine/swarm/stack-deploy/#push-the-generated-image-to-the-registry


örnek: bir pytonn kodunu build alıp docker-compose ile push edip daha sonra docker stack ile deploy etmek

```
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = redis.incr('hits')
    return 'Hello World! I have been seen {} times.\n'.format(count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
```

pyton requirement yüklemeleri için requirements.txt dosyası açıp içine şunlarıyazıyoruz

```
flask
redis
```

Dockerfile ımız
```
FROM python:3.4-alpine
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

docker compose file ımız
```
version: '3'

services:
  web:
    image: 127.0.0.1:5000/stackdemo
    build: .
    ports:
      - "8000:8000"
  redis:
    image: redis:alpine
```

şimdi push ediyoruz

```
docker-compose push
```
daha sonra deploy ediyoruz

```
docker stack deploy --compose-file docker-compose.yml stackdemo
```
daha sonra chek ediyoruz

```
docker stack services stackdemo


ID            NAME             MODE        REPLICAS  IMAGE
orvjk2263y1p  stackdemo_redis  replicated  1/1       redis:3.2-alpine@sha256:f1ed3708f538b537eb9c2a7dd50dc90a706f7debd7e1196c9264edeea521a86d
s1nf0xy8t1un  stackdemo_web    replicated  1/1       127.0.0.1:5000/stackdemo@sha256:adb070e0805d04ba2f92c724298370b7a4eb19860222120d43e0f6351ddbc26f

```

