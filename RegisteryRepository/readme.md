### Kurumlarda kaşılaşılabilecek hatalar

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

- https://stackoverflow.com/questions/50151833/cannot-login-to-docker-account
- https://hasanyousuf.com/2019/09/21/how-to-install-sonatype-nexus-3-on-centos6-10/
- https://qiita.com/leechungkyu/items/86cad0396cf95b3b6973
- https://medium.com/@acokgungordu/nexus-repository-manager-3%C3%BC-depo-olarak-kullanma-docker-images-71ef1b2ccdea
- https://medium.com/@acokgungordu/nexus-repository-manager-3%C3%BC-depo-olarak-kullanma-docker-images-71ef1b2ccdea




### Kurulum

- https://qiita.com/leechungkyu/items/86cad0396cf95b3b6973
- https://help.sonatype.com/repomanager3/installation/installation-methods#InstallationMethods-InstallingwithDocker
- https://hub.docker.com/r/sonatype/nexus3/


1. docker ı kuruyoruz


https://docs.docker.com/engine/install/ubuntu/


```
# versiyon olarak 5:19.03.13~3-0~ubuntu-bionic kurduk

$  sudo apt-get install docker-ce=5:19.03.13~3-0~ubuntu-bionic docker-ce-cli=5:19.03.13~3-0~ubuntu-bionic  containerd.io

```

2. daha sonra nexus verileri için persistant volume oluşturuyoruz: 

- https://docs.docker.com/storage/volumes/
- https://hub.docker.com/r/sonatype/nexus3/#persistent-data

```
$ sudo docker volume create --name nexus-data
```

3. daha sonra alttaki komutla kuruyoruz

versiyon olarak nexus3:3.27.0 kuruyoruz. 

şu patha volume create edilmiş olacak.

var/lib/docker/volumes/nexus-data/

```
$ sudo docker run --name nexus -e INSTALL4J_ADD_VM_PARAMS="-Xms1g -Xmx1g -XX:MaxDirectMemorySize=2g" -d -p 5000:5000 -p 8081:8081 -v nexus-data:/nexus-data sonatype/nexus3:3.27.0

```

Daha sonra http://40.74.62.251:8081 adresinden bağlanabiliriz.



### Nexus 3 üzerinde docker repository sinde delete policy

https://help.sonatype.com/repomanager3/repository-management/cleanup-policies#CleanupPolicies-AssetNameMatcher

Published Before (Days):  belli bir günden önce oluşturulanları sil. yani en fazla kaç gün korunacağını belirtiyoruz. 30 olduğunu varsayalım
Last Downloaded Before (Days): belirlenen günden önce image kullanılmadıysa sil. 20 olduğunu varsayalım

örneğin bir image 25 gün önce create olmuş ancak 21 gündür kullanılmamış ozaman silinir.

uygulanan policy ler beraber çalışır.

### Nexus 3 üzerinde Docker Repository oluşturmak

- Öcelikle blob (storage) ouşturuyoruz. (üstte çark resmine tıklayıp soldaki menüden repoository ye tıklarsak görülebilir.)
- daha sonra soldan reporittory alttındaki repositories e tıklayıp oluşturabiliriz ya da hazırlardan kullanbiliriz.


8081 den 8090 a kadar portlat expose eilirse iyi olur. (her repo için bir porta ihtiyacımız olacak)

exus 3 web portu 8081, web sitesi için açılan herbir repository için port ataması yapmak lazım. 



Nexus u registery olarak kullancak olan **Docker**da http ile registery yapılmak isteniyorsa insecure regitery yapıması lazım öncelikle

- https://docs.docker.com/registry/insecure/

    /etc/docker/daemon.json doyası create edilip (eğer değilse) alttaki bölüm eklnemeli

5000 portunu kendi (Nexus üzerinde) repomuzu create ederken girmiştik nexus 3 ekranında. Login olurken pu portu kullanıyoruz.

buradan şu çıkıyor her repo için bir port girmemiz lazım ya da group oluşturmak lazım.

```
{
  "insecure-registries" : ["privatereg.com:5000"]
}
```

buda dikkaet edilirse domain olarka privatereg.com yazıyor . Bu domaini docker sunucusunun host una yazlamalıyız. yani docker a bu adresteki 5000 portundan image alacağımızı veya image koyacağımızı söylemiş olduk. 

eğer image registery niniz docker ile aynı sunucudayda 127.0.0.1 diyebiliriz.


daha sonra 

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

öcelikle repoya login olmamız lazım

```
$ sudo docker login -u admin -p admin123 privatereg.com:5000
```



- https://docs.docker.com/engine/reference/commandline/push/

örnek push komutları

```

$ docker tag rhel-httpd:12.03 registry-host:5000/myadmin/rhel-httpd:12.04

$ docker push registry-host:5000/myadmin/rhel-httpd:12.04

```



### Jenkins kurulumu

docker hub da dikkat edilmeli yanlışlıkla sadece jenkins yazan image ları yükleme. Onlar deprecated artık yeni imaje larda jenkins/jenkins yazıyor. 

birde jebkins in yeni nesil UI i ve pipeline işlettme şekli olan blue ocean versiyonu var. onun registery adrsi farklı ve clasiğe göre bazı farklılıkları olduğı için niz clasik olan versiyonu yüklüyoruz.


jenkins makinasına aynı zamanda docker kurmuş olmalıyız zaen nexus u kurarken kullandığımız versionu jenkins makinaısnada kurduğumuz varsayıyoruz

```
$ adduser jenkins
$ cat /etc/passwd | grep jenkins

# sonuç

jenkins:x:1001:1001::/home/jenkins:/bin/bash

```
daha sonra bu id yi altta kullanacağız

birde var altıda jenkins_home diye bir klasör açıyoruz.




daha sonra log kısmını ayarlıyoruz

```
$ sudo -u jenkins cat > /var/jenkins_home/log.properties <<EOF
handlers=java.util.logging.ConsoleHandler
jenkins.level=FINEST
java.util.logging.ConsoleHandler.level=FINEST
EOF

```
klasöürn içindekilerle birlikte sahibini jenkins kullanıcısı yapıyoruz

```
$ sudo chown -R 1001:1001 /var/jenkins_home
```





```
$ sudo docker run --name myjenkins --restart unless-stopped -d -u 1001 -p 8080:8080 -p 50000:50000 --env JAVA_OPTS="-Djava.util.logging.config.file=/var/jenkins_home/log.properties" -v /var/jenkins_home:/var/jenkins_home jenkins/jenkins:2.249.1-lts-centos7
```

-d detach mode demektir, --rm stop olan container ı siler

eğer restart sttrategy belirlemediysek daha sonra bütün containerlarıda elle stop edilcene kadar restart etmesini sağlaycak kod

```
$  sudo docker update --restart unless-stopped $(sudo docker ps -q)

```



password için artık host makinasında alttaki komutu çalıştırabiliriz.

```
$ sudo cat /var/jenkins_home/secrets/initialAdminPassword
```

adres: http://13.95.194.157:8080/




docker ve jenkins üzerine 8 derslik blog. resimli anlatım

https://technology.riotgames.com/news/thinking-inside-container



### örnek hazır bir image ı tagleyip private registery mize push edelim ve daha sonra private registery den pull edelim.

https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images?view=aspnetcore-3.1

1. örnek uygulamayı clone la

```
$ git clone https://github.com/dotnet/dotnet-docker
```

2. Bocker image oluşturulur

dotnet-docker/samples/aspnetapp pathine gidiyoruz ve docker file ı nceliyoruz.

dockerfile da görüldüğü üzere buld alma işlemi de dcoker içinde yapılıyor.

```
# https://hub.docker.com/_/microsoft-dotnet-core
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetapp/*.csproj ./aspnetapp/
RUN dotnet restore

# copy everything else and build app
COPY aspnetapp/. ./aspnetapp/
WORKDIR /source/aspnetapp
RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "aspnetapp.dll"]
```


artık build alabiliriz.

```
$ docker build -t aspnetapp .
```

build sonucunda docker bize ya bir commit id verecek yada bu örnekte olduğu gibi latest olarak uygulamayı tag leyeek


build sonucu
```
Successfully built d60f075b69b1
Successfully tagged aspnetapp:latest
```

image listesini check ettiimizde de görebiliriz

```
$ docker image ls

# sonuç

REPOSITORY                             TAG                   IMAGE ID            CREATED             SIZE
aspnetapp                              latest                d60f075b69b1        2 minutes ago       212MB

```


3. daha sonra image ımızı tagliyoruz ve private registery mize push ediyoeuz. dikkat etmek lazım burada tag olarak version numarası da kullanıyor olacağız.



```
$ docker tag aspnetapp:latest privatereg.com:5000/aspnetapp:1.0.0

# tekrar image listesine bakacak olursak. socnuç

REPOSITORY                             TAG                   IMAGE ID            CREATED             SIZE
aspnetapp                              latest                d60f075b69b1        7 minutes ago       212MB
privatereg.com:5000/aspnetapp          1.0.0                 d60f075b69b1        7 minutes ago       212MB

```


daha sonra bu image ı push edebiliriz.

```
$ docker push privatereg.com:5000/aspnetapp:1.0.0
```

daha sonra Nexus 3 de check edecek olursak repositoey içinde aspnetapp 1.0.0 versiyonunu görebiliriz.

aynı latest ı tekrar version 2.0.0 olarak taglaeiyp push layıp naxusa bakacak olursak eski 1.0.0 olanın extradan 2.0.0 olarak da taglandiğini ve hash inin değişmediğini nexus panelinden görebiliriz


4. şimdi farkı bi veryion daha çıkabilmek için uygulamda biryerleri değiştirip terar build alıp taglarken 3.0.0 olarka tagleyeleim.



```
$ docker tag aspnetapp:latest privatereg.com:5000/aspnetapp:1.0.0

$ docker push privatereg.com:5000/aspnetapp:1.0.0

```


ufak bir değişiklik yapıp tag ıtekrar attığımızda yeni bir hash in oluştuğunu görebiliriz.




### JEnkins Docker komutları build ve register için

docker kurulu olan agent da nexuss 3 private registery ye login olunduktan sonra home altında ki admin kullanıcısının alıdna yer alan .docker klasöründeki config.json dosyasını /home/jenkins alrıdna açılacak olan .docker klasörüne koyapalanmalı.


Build alırken tag atmak

privatereg.com:5000 daha önce docker tarafında  login olunmuş private registery adresi

version kısmı parametre olarak alınıp jenkinde rapametre olarka da docker komutuna eklenebilir.


```
$ docker build -t privatereg.com:5000/kubernetes:v1.0.0

```

Örnek parametrik taglemek. Dockerfile klasörünün olduğu yerde olmalıyız tabii ki.

```
$ docker build -t privatereg.com:5000/kubernetes:${version}

```

path belirterek docker build

```
docker build "${WORKSPACE}/samples/aspnetapp" -t privatereg.com:5000/kubernetes:${Versiyon}
```


birden  fazla tag atmak için

```
$ docker build -t whenry/fedora-jboss:latest -t whenry/fedora-jboss:v2.1

```


build alınmış bir docker image ı taglemek

```
$ docker tag aspnetapp:latest privatereg.com:5000/aspnetapp:v1.0.0

```
image ı deploy etmek

```
$ docker push privatereg.com:5000/aspnetapp:1.0.0
```



### kubernets

https://www.jenkins.io/doc/pipeline/steps/kubernetes/

https://github.com/jenkinsci/kubernetes-plugin



kubernettes için jankins makinasında alttaki işlemler yapılmalı







**Kısıtlı yetkili kullanıcı oluşturma**

jenkins agent kurulu makinamızda jenkins kullanıcısı ile kubernetes e işlemler yapabilmek amacıyla user, role ve rolebinding oluştturuyoru.


amacımız jenkinsin listedeğki objeleri  yöntebilceği bir kullanıcı oluşturmak.

- Pod
- Service
- Volume
- Deployment
- DaemonSet
- StatefulSet
- ReplicaSet
- Job


oluşturağımız kullanıcı sadece default ve testnamespace inde yettki olacak.

 Daha sonra bu kullanıcıyı agent makinasına kuracağımız kubectl ile ve jenkins kullanıcının home klasörüne oluşturacağımz .kube klasörü altındaki config doyasınuı kullanrak yetkilendireceğiz.


 çalışmada listeki libkler kullanıldı
 - https://kubernetes.io/docs/reference/access-authn-authz/authentication/

- https://docs.bitnami.com/tutorials/configure-rbac-in-your-kubernetes-cluster/


1. **testnamespace ini oluşturuyoruz**

```
$ kubectl create namespace testnamespace
```

2. **kullanıcı hesabı oluşturuyoruz**

jenkins kullanıcısı için  private key oluşturuyoruz

```
$ sudo -u jenkins openssl genrsa -out jenkins.key 2048
```

daha sonra key i kullanarak certificate sign request oluştturuyoruz.

```
$ sudo -u jenkins openssl req -new -key jenkins.key -out jenkins.csr -subj "/CN=jenkins"
```

son olarak crt uzantılı sertifikamızı oluşturuyoruz. Ancak tam bu noktoda Ca.crt ve Ca.key dosyalrına ihtiyacımız olacak. bu dosyaların altt6aki komutun çalıştırıldığı klasörde olduğunu varsayıyoruz.

```
$ sudo -u jenkins openssl x509 -req -in jenkins.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out jenkins.crt -days 3600
```

son olarak bu sertifikarı config dosylarımıza cedential ve context set ederek tanımlıyoruz.ancak şuna dikkat edilmeli bu iki crt ve key uzantılı dosya jenkins home klasöründe olmalı ve jenkins jkullanıcısı yetkili olmalı ayrıca eğer bu işlemler jenkins kullanıcısı dışında bir kullanısıyla yapılıyorsa "sudo " prefix kullanılarak komutlar yazılmalı.

eğer jenkins dışında bir kullanıcı ile yapıyorsak

```
$ sudo kubectl config set-credentials jenkins --client-certificate=jenkins.crt  --client-key=jenkins.key --kubeconfig=.kube/config --user=jenkins

$ sudo kubectl config set-context jenkins-context --cluster=cluster.local --user=jenkins --kubeconfig=.kube/config
```

olurda hata yapılırsa user ve context silmek için

```
$ sudo kubectl config unset users.jenkins --client-certificate=jenkins.crt  --client-key=jenkins.key --kubeconfig=.kube/config --user=jenkins
$ sudo kubectl config unset contexts.jenkins-context --cluster=cluster.local --user=jenkins --kubeconfig=.kube/config
```



test etmek için 
```
$ sudo kubectl get pod --client-certificate=jenkins.crt  --client-key=jenkins.key --kubeconfig=.kube/config --user=jenkins --context=jenkins-context
```

testt sonucu beklenildiği gibi 

```
Error from server (Forbidden): pods "jenkins" is forbidden: User "jenkins" cannot get resource "pods" in API group "" in the namespace "default"

```


çünki bu kullanıcı için bir yetki ttanımlaması yapmamıştık.


3. **role oluşturuyoruz**

files klasöründeki yaml dosyası role-deployment-manager-testnamespace.yaml 


burada görüldüğü üzere role üzerinde namespace kısıttlamaı yapılmış. eğer burada değilde aşağıda role-binding üzerinde bu kısıtlama yapılıp birden fazla role de bu rolebinding kullanılarak namespave kısıtlaması da yapılabilir. örnek kullanım için [link](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-example).

birde şuna dikkat emek lazım bu bir role, clusterRole değil. eğer öyle olsaydı namespacve kısıtlaması zaten garip olurdu. zaten yapılamıyorda.

- https://unofficial-kubernetes.readthedocs.io/en/latest/admin/authorization/rbac/
- https://docs.bitnami.com/tutorials/configure-rbac-in-your-kubernetes-cluster/
- https://medium.com/faun/kubernetes-rbac-use-one-role-in-multiple-namespaces-d1d08bb08286 (use one Role in multiple namespaces)

ayrıca bu sadece testnamespace için bir role birde default için lazım. oda failes klasörü altında

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: testnamespace
  name: deployment-manager-testnamespace
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods","services","volumes","replicasets","jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]

```

bu iki role ude deploy ediyoruz.

```
$ kubectl create -f role-deployment-manager-testnamespace.yaml
$ kubectl create -f role-deployment-manager-default.yaml


```

4. **RoleBinding create ediyoruz**

roleRef tanımı array tipinde olmadığı için API dökünalarından kontrol edilebilir. mecburen 2 tane rolebinding oluşturduk. aslında burada namespace tanıumına gerek yok çünki role tanımında zaten vardı. tek doya içine iki tanım yaptık.

```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: deployment-manager-testnamespace-binding
  namespace: testtnamespace
subjects:
- kind: User
  name: jenkins
  apiGroup: ""
roleRef:
  kind: Role
  name: deployment-manager-testnamespace
  apiGroup: ""
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: deployment-manager-default-binding
  namespace: default
subjects:
- kind: User
  name: jenkins
  apiGroup: ""
roleRef:
  kind: Role
  name: deployment-manager-default
  apiGroup: ""
```

yaml dosyasını çalıştırıyorus


```
$ kubectl create -f rolebinding-deployment-manager.yaml
```

şimdi tekrar ttest tediyoruz. jenkins makinamızda


namespace pelirttmediğimiz için default da yapmş olacak.

```
$ sudo kubectl get pod --client-certificate=jenkins.crt  --client-key=jenkins.key --kubeconfig=.kube/config --user=jenkins --context=jenkins-context
```


sonuç olarak pod lar listelenmiş olacak.




5. **kubernetes de pod ayağa kaldırıp servis ile expose etmek**


öncelikle bütün node lar üzerinde docker için  yukarıda anlatıldığı üzere insecure login yapılmalı.

daha sonra kubernetes tarafında ilgili private registery için kubernetes.io/dockerconfigjson tipinde secret oluşturulmalı.

bunun iki yolu var halihazırda private registery login olmuş bir docker dan alınabilir yada kubernetes üzerinde imperative ve declarative bir yolla opluşturlur.

kubectl docker ile aynı makinada ise

```
$ kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
```

imperative yolla
```
$ kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```
bizde mail daresi yok ancak docker private hub kullanıyor olsaydık gerekebilirdi.

docker-registry tipinde adı regcred olan bir secret oluşturuyoruz.

```
$ kubectl create secret docker-registry regcred --docker-server=http://privatereg.com:5000 --docker-username=admin --docker-password=abc123
```

işlem sonucuna bakacak olursak

```
$ kubectl get secret regcred --output=yaml
# sonuç

apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwOi......WluIiwicGFzc3dvcmQ......emc1SVE9PSJ9fX0=
kind: Secret
metadata:
  creationTimestamp: "2020-09-25T06:48:09Z"
  name: regcred
  namespace: default
  resourceVersion: "3039270"
  selfLink: /api/v1/namespaces/default/secrets/regcred
  uid: 6ac7f9b2-3f00-4e63-b284-3a79f98babb7
type: kubernetes.io/dockerconfigjson

```

imperative yolla private registery deki image ı kuberntes e jenkins üzerinden göndreceğiz. ayrıca yeni versiyonun da update ini yapacağız.


port servisin yayınlarken kullandığı port target-port ise dockerfile da yazan yani container ın uygulamayı yayınladığı port. 

```
# start the pod running nginx

$ kubectl create deployment --image=privatereg.com:5000/aspnetapp:1.0.0 myaspnetapp

$ kubectl expose deployment myaspnetapp --port=8005 --target-port=80 --name=myaspnetapp-service

```

yanlzı yukarıdaki kod deployment a imagePullSecrets pec ini eklemediğimiz için çalışmayacaktır. bunun için pod veya deployment yaml doaysına imagePullSecrets spec ini eklememiz gerekecek yada imperative yolu tercih ediyorsak jspn formatta geçirmemiz gerekiyor. yada son tercih ilgili deployemnet yada pod edilebilir.

- https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod


diğer yollar ise 

- However, setting of this field can be automated by setting the imagePullSecrets in a ServiceAccount resource.

Check Add ImagePullSecrets to a Service Account for detailed instructions.

- You can use this in conjunction with a per-node .docker/config.json. The credentials will be merged.





örnek pod 

```
apiVersion: v1
kind: Pod
metadata:
  name: foo
  namespace: awesomeapps
spec:
  containers:
    - name: foo
      image: janedoe/awesomeapp:v1
  imagePullSecrets:
    - name: myregistrykey #    <<<--------------------------

```





### kubernets kaynaklarini imperative olarak update etmek


örneğin yukarıdaki uygulamayı başka bir versiyona çekmek için alttaki gibi bir komut kullanılır. normalde v1.0.0 dı.

hatırlarsanız deployment ı create ederken şu komutu kullanmıştık _kubectl create deployment --image=privatereg.com:5000/aspnetapp:1.0.0 myaspnetapp_

aspnetapp container adı olarak atanınır. 

yani alttaki komutta şu kısımda _aspnetapp=privatereg.com:5000/aspnetapp:v2.0.0_ aspnetapp container adı, eşittirin karşısı ise yeni image adı ve versiyopnu olarak kullanılır.


```
$ kubectl set image deployment/myaspnetapp aspnetapp=privatereg.com:5000/aspnetapp:v2.0.0
```


ancak bunu yapsak da image ın pull edilmediğini göreceğiz.

konuyla ilişkili linkler

- https://medium.com/@IlyasKeser/deployment-rolling-update-and-rollback-with-kubernetes-ab8707dc1149
- https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/workloads/controllers/deployment/
- https://learnk8s.io/kubernetes-rollbacks
- https://kubernetes.io/docs/concepts/containers/images/#updating-images


burada deploy tipimiz önemli. default olarak IfNotPresent ayarlıdır.

- Always
- IfNotPresent
- Never

bu durumda

- set the imagePullPolicy of the container to Always.
- omit the imagePullPolicy and use :latest as the tag for the image to use.
- omit the imagePullPolicy and the tag for the image to use.
- enable the AlwaysPullImages admission controller. https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages


revision history ve rollout 

```
$ kubectl rollout history deployment/app

$ kubectl rollout undo deployment/app --to-revision=2

```



- https://kubernetes.io/docs/reference/kubectl/cheatsheet/






- **Updating resources**

```
kubectl set image deployment/frontend www=image:v2               # Rolling update "www" containers of "frontend" deployment, updating the image
kubectl rollout history deployment/frontend                      # Check the history of deployments including the revision 
kubectl rollout undo deployment/frontend                         # Rollback to the previous deployment
kubectl rollout undo deployment/frontend --to-revision=2         # Rollback to a specific revision
kubectl rollout status -w deployment/frontend                    # Watch rolling update status of "frontend" deployment until completion
kubectl rollout restart deployment/frontend                      # Rolling restart of the "frontend" deployment


cat pod.json | kubectl replace -f -                              # Replace a pod based on the JSON passed into std

# Force replace, delete and then re-create the resource. Will cause a service outage.
kubectl replace --force -f ./pod.json

# Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000
kubectl expose rc nginx --port=80 --target-port=8000

# Update a single-container pod's image version (tag) to v4
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

kubectl label pods my-pod new-label=awesome                      # Add a Label
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # Add an annotation
kubectl autoscale deployment foo --min=2 --max=10                # Auto scale a deployment "foo"
```


- **Patching resources**

```
# Partially update a node
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'

# Update a container's image; spec.containers[*].name is required because it's a merge key
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'

# Update a container's image using a json patch with positional arrays
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'

# Disable a deployment livenessProbe using a json patch with positional arrays
kubectl patch deployment valid-deployment  --type json   -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}]'

# Add a new element to a positional array
kubectl patch sa default --type='json' -p='[{"op": "add", "path": "/secrets/1", "value": {"name": "whatever" } }]'
```















