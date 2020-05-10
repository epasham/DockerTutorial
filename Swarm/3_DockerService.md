### Docker Service Commands

#### docker service create

https://docs.docker.com/engine/reference/commandline/service_create/

docker service create [OPTIONS] IMAGE [COMMAND] [ARG...]

This is a cluster management command, and must be executed on a swarm manager node. To learn about managers and workers, refer to the Swarm mode section in the documentation.


private registery den eğer service create edilcekse
```
$ docker login registry.example.com

$ docker service  create \
  --with-registry-auth \
  --name my_service \
  registry.example.com/acme/my_image:latest
```

5 replicate set ile create

```
docker service create --name redis --replicas=5 redis:3.0.6
```
create with secret

```
docker service create --name redis --secret secret.json redis:3.0.6
```

create with config

```
docker service create --name=redis --config redis-conf redis:3.0.6

```
Create a service with a rolling update policy

```
$ docker service create \
  --replicas 10 \
  --name redis \
  --update-delay 10s \
  --update-parallelism 2 \
  redis:3.0.6
```
create service with env (bunun için işte docker stack kullanmalıyız. çünki hangi ayarları yaptık belli değil. ama yaml de direct yazıyor)

```
$ docker service create \
  --name redis_2 \
  --replicas 5 \
  --env MYVAR=foo \
  redis:3.0.6


$ docker service create \
  --name redis_2 \
  --replicas 5 \
  --env MYVAR=foo \
  --env MYVAR2=bar \
  redis:3.0.6

```

create service with lebel
```
$ docker service create \
  --name redis_2 \
  --label com.example.foo="bar"
  --label bar=baz \
  redis:3.0.6

```


create service with named volume

```
$ docker service create \
  --name my-service \
  --replicas 3 \
  --mount type=volume,source=my-volume,destination=/path/in/container,volume-label="color=red",volume-label="shape=round" \
  nginx:alpine

```

- Specify service constraints (--constraint)

You can limit the set of nodes where a task can be scheduled by defining constraint expressions. Constraint expressions can either use a match (==) or exclude (!=) rule. Multiple constraints find nodes that satisfy every expression (AND match). Constraints can match node or Docker Engine labels as follows:

```
node attribute      matches                     example
node.id             Node ID	                    node.id==2ivku8v2gvtg4
node.hostname       Node hostname	            node.hostname!=node-2
node.role           Node role (manager/worker)  node.role==manager
node.platform.os    Node operating system	    node.platform.os==windows
node.platform.arch  Node architecture           node.platform.arch==x86_64
node.labels	        User-defined node labels    node.labels.security==high
engine.labels       Docker Engine’s labels      engine.labels.operatingsystem==ubuntu-14.04

```

```
$ docker service create \
  --name web \
  --constraint node.labels.region==east \
  nginx:alpine

lx1wrhhpmbbu0wuk0ybws30bc
overall progress: 0 out of 1 tasks
1/1: no suitable node (scheduling constraints not satisfied on 5 nodes)

$ docker service ls
ID                  NAME     MODE         REPLICAS   IMAGE               PORTS
b6lww17hrr4e        web      replicated   0/1        nginx:alpine

```


```
$ docker node update --label-add region=east yswe2dm4c5fdgtsrli1e8ya5l
yswe2dm4c5fdgtsrli1e8ya5l

$ docker service ls
ID                  NAME     MODE         REPLICAS   IMAGE               PORTS
b6lww17hrr4e        web      replicated   1/1        nginx:alpine

```

specify max perplica per node
```
$ docker service create \
  --name nginx \
  --replicas 2 \
  --replicas-max-per-node 1 \
  --placement-pref 'spread=node.labels.datacenter' \
  nginx
```

- Publish service ports externally to the swarm (-p, --publish)
  
```
$ docker service create --name my_web --replicas 3 --publish published=8080,target=80 nginx
```

- Create services using templates

```
Placeholder     Description
.Service.ID     Service ID
.Service.Name   Service name
.Service.Labels Service labels
.Node.ID        Node ID
.Node.Hostname  Node Hostname
.Task.ID        Task ID
.Task.Name      Task name
.Task.Slot      ask slot
```



```
$ docker service create \
    --name hosttempl \
    --hostname="{{.Node.Hostname}}-{{.Node.ID}}-{{.Service.Name}}"\
    busybox top

va8ew30grofhjoychbr6iot8c

$ docker service ps va8ew30grofhjoychbr6iot8c

ID            NAME         IMAGE                                                                                   NODE          DESIRED STATE  CURRENT STATE               ERROR  PORTS
wo41w8hg8qan  hosttempl.1  busybox:latest@sha256:29f5d56d12684887bdfa50dcd29fc31eea4aaf4ad3bec43daf19026a7ce69912  2e7a8a9c4da2  Running        Running about a minute ago

$ docker inspect --format="{{.Config.Hostname}}" 2e7a8a9c4da2-wo41w8hg8qanxwjwsg4kxpprj-hosttempl

x3ti0erg11rjpg64m75kej2mz-hosttempl
```
#### docker service inspect

```
$ docker service inspect --pretty frontend

ID:     c8wgl7q4ndfd52ni6qftkvnnp
Name:   frontend
Labels:
 - org.example.projectname=demo-app
Service Mode:   REPLICATED
 Replicas:      5
Placement:
UpdateConfig:
 Parallelism:   0
 On failure:    pause
 Max failure ratio: 0
ContainerSpec:
 Image:     nginx:alpine
Resources:
Networks:   net1
Endpoint Mode:  vip
Ports:
 PublishedPort = 4443
  Protocol = tcp
  TargetPort = 443
  PublishMode = ingress
```

#### docker service log

docker service logs [OPTIONS] SERVICE|TASK

#### docker service rm

docker service rm SERVICE [SERVICE...]

#### docker service rm

docker service rm SERVICE [SERVICE...]

#### docker service rollback

Use the docker service rollback command to roll back to the previous version of a service. After executing this command, the service is reverted to the configuration that was in place before the most recent docker service update command.

The following example creates a service with a single replica, updates the service to use three replicas, and then rolls back the service to the previous version, having one replica.

Create a service with a single replica:
```
$ docker service create --name my-service -p 8080:80 nginx:alpine
```
#### docker service scale


The following command scales the “frontend” service to 50 tasks.

```
$ docker service scale frontend=50

frontend scaled to 50
```

swarm modda service modu belirtilmezse reaplicated olarak başlar ki debest practice de budur. birde global mode var, burada da bütün node larda  placement constraints and resource requirements karşılacayak şekilde container ları çalıştırmaya çalışır.

The following command tries to scale a global service to 10 tasks and returns an error.
```
$ docker service create --mode global --name backend backend:latest

b4g08uwuairexjub6ome6usqh
```

```

$ docker service scale backend=10

backend: scale can only be used with replicated mode

```

#### docker service update


Updates a service as described by the specified parameters. The parameters are the same as docker service create. Refer to the description there for further information.

daha önce creat edilmiş bir service in parametrelerinin updarte edilmesini sağlar. bu nedenle option ları create ile hemen hemen aynıdır

https://docs.docker.com/engine/reference/commandline/service_update/

