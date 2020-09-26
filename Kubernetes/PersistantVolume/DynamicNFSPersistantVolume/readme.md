### RBAC kavramı

https://kubernetes.io/docs/reference/access-authn-authz/rbac/

- Role and ClusterRole

An RBAC Role or ClusterRole contains rules that represent a set of permissions. Permissions are purely additive (there are no "deny" rules).


A Role always sets permissions within a particular namespace ; when you create a Role, you have to specify the namespace it belongs in.


ClusterRole, by contrast, is a non-namespaced resource. The resources have different names (Role and ClusterRole) because a Kubernetes object always has to be either namespaced or not namespaced; it can't be both.

ClusterRoles have several uses. You can use a ClusterRole to:

    - define permissions on namespaced resources and be granted within individual namespace(s)
    - define permissions on namespaced resources and be granted across all namespaces
    - define permissions on cluster-scoped resources


- RoleBinding and ClusterRoleBinding

A role binding grants the permissions defined in a role to a user or set of users. It holds a list of subjects (users, groups, or service accounts), and a reference to the role being granted. A RoleBinding grants permissions within a specific namespace whereas a ClusterRoleBinding grants that access cluster-wide.

A RoleBinding may reference any Role in the same namespace. Alternatively, a RoleBinding can reference a ClusterRole and bind that ClusterRole to the namespace of the RoleBinding. If you want to bind a ClusterRole to all the namespaces in your cluster, you use a ClusterRoleBinding.

### Dynamic NFS Persistent Volume in Kubernetes Cluster

**dikkat bu örnekte claim policy dynamic de delete bu nedenle pod silindiğinde nfs dekialanda silinir. eğer silinememesi isteniyorsa retain olarak ayarlanmalı.**

Diğerlerinden farklı olarak dynamic olan persistant volume lerde bi provisioner a ihtiyaç vardır. Burada örneğin NFS client provisionar a ihtiyacımız olacak.

google da aratacak olursak alttaki sayfalar çıkacaktır.
- https://github.com/kubernetes-retired/external-storage/tree/master/nfs-client 

bu sayfa artık read only. daha önce aslında Kubernetes Incubator adında bir pje altındaymış ancak [artık alt projelere bölünmüş](https://github.com/kubernetes/community/blob/master/incubator.md). 

- https://github.com/kubernetes/community/tree/master/sig-storage

bu sayfaya göre NFS client privisionar iki farklı proje olarka community tarafından yürütülüyor.

- https://raw.githubusercontent.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/master/OWNERS
- https://raw.githubusercontent.com/kubernetes-sigs/nfs-subdir-external-provisioner/master/OWNERS


nfs-ganesha-server-and-external-provisioner sayfası

- https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner


nfs-subdir-external-provisioner sayfası. bu proje üstte bahsi geçen artık deprecated olan projenin aynısı artık buradan devam edecekmiş.

- https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner


ancak biz burada deprecated olan projeyle devam ediyor olacağız.

1. **NFS server kurulmuş ve tüm node lardan ulaşılabiliyor olmalı**

2. **Alttaki sayfada deploy klasöründen class.yaml, deployment.yaml ve rbac.yaml dosyalrını alıyoruz. dosyalar files klasörüne kopyalandı.**

https://github.com/kubernetes-retired/external-storage/tree/master/nfs-client


öncelikle rbac.yaml dosyaıyla başlıyoruz.


bu doysada aslında 3 farklı deployment yapılıyor

- nfs-client-provisioner isimli ServiceAccount:
```
kind: ServiceAccount
apiVersion: v1
metadata:
  name: nfs-client-provisioner
```


- nfs-client-provisioner-runner isimli ClusterRole: bu role: kuralları yaml dosyasında şu şekilde. görüldüğü üzere bu role sade persistent resource u üzerinde yetkili.

```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
```
- run-nfs-client-provisioner isimli ClusterRoleBinding:  service account (nfs-client-provisioner) ile cluster role (nfs-client-provisioner-runner) u birbirinre bind eder.
```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
```

- leader-locking-nfs-client-provisioner isimli Role: cluster seviyesinde olmayacak olan role. namescpace seviyesinde role binding ile bind edilir. bu role büyük ihtimalle yazma konusunda birden fazla yazma olmaması için lock lama yapıyor. konu ile ilgili örnek go dili ile yazılmış proje [linki](https://carlosbecker.com/posts/k8s-leader-election).

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
```

- leader-locking-nfs-client-provisioner isimli RoleBinding: servis account u ile Role (leader-locking-nfs-client-provisioner) binde eder.
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io
```

rback.yaml dosyasını create ediyoruz.


```
$ kubectl create -f files/rbac.yaml
#sonuç

serviceaccount/nfs-client-provisioner created
clusterrole.rbac.authorization.k8s.io/nfs-client-provisioner-runner created
clusterrolebinding.rbac.authorization.k8s.io/run-nfs-client-provisioner created
role.rbac.authorization.k8s.io/leader-locking-nfs-client-provisioner created
rolebinding.rbac.authorization.k8s.io/leader-locking-nfs-client-provisioner created

```


3. **Şimdi StorageCluster ı create ediyoruz.**

StorageClass dynamic olarka dtorage create edecek olan component.

```
$ kubectl create -f files/class.yaml
```

4. **Şimdi deployment yapacağız**

bu deployment da aslında bir pod ayağa kaldırmış olacağız. biz storage talep ettiğimizde bize dinamik olarak ilgili volume u sunacak olan pod olmuş olacak.

ilgili dosyanın caontainer kısmı incelenek olursa. Bu kontainer bazı ENV variables istiyor olduğu görülebilir. buraya nfs server ile ilgili bilgileri giriyoruz.

```
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: example.com/nfs
            - name: NFS_SERVER
              value: 10.0.1.4
            - name: NFS_PATH
              value: /media/diskshared/dynamic
      volumes:
        - name: nfs-client-root
          nfs:
            server: 10.0.1.4
            path: /media/diskshared/dynamic

```
oluşturuyoruz

```
$ kubectl create -f files/deployment.yaml
```


5. **şimdi test etmek için bir PVC oluşturacağız.**


files klasorunde dynamic-pvc-nfs.yaml diye bir dosya var. bu dosyada özellikle StorageClass adına dikkat ememiz gerekiyor. Daha önce oluşturduğumuz StorageClass adıyla aynı olmalı.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc-nfs-pv1
spec:
  storageClassName: managed-nfs-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 500Mi


```

bunu da create ediyoruz

```
$ kubectl create -f files/dynamic-pvc-nfs.yaml
```

testt edecek olursak

```
$ kubectl get pvc

# sonuç

NAME                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
dynamic-pvc-nfs-pv1   Bound    pvc-59906622-c82c-418f-8d2a-cf2106679d7b   500Mi      RWX            managed-nfs-storage   17m
pvc-nfs-pv1           Bound    pv-nfs-pv1                                 1Gi        RWX            manual                19h

```

eğer pendingde uzun süre kalır describe ile bakılabilir. nfs de açtığınız klasöre 777 verdiğinizden emin olun.


6. **daha sonra bu pvc yi kullancak bir uygulamayı ayağa kaldırıyoruz**

bunun için files klasörü altındaki dynamic-busybox-pv-hostpath.yaml dosyasını kullanıyor olcağız.


dosyada dikkaet etmemiz gereken yer claimName: dynamic-pvc-nfs-pv1 daha önce oluşturduğumuz claimin adını giriyoruz.

```
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-busybox
spec:
  volumes:
  - name: host-volume
    persistentVolumeClaim:
      claimName: dynamic-pvc-nfs-pv1
  containers:
  - image: busybox
    name: busybox
    command: ["/bin/sh"]
    args: ["-c", "sleep 600"]
    volumeMounts:
    - name: host-volume
      mountPath: /mydata

```

şimdi create ediyoruz

```
$ kubectl create -f files/dynamic-busybox-pv-hostpath.yaml
```

şimdi bu pod içindeki container a birşeyler yazıp gerçekten mount edilip edilmediğine bakalım.


```
$ kubectl exec -it dynamic-busybox -- sh

# mydata klasörü mount edilmişti içine bir dosya oluşturup sonra check edeceğiz.

touch mydata/test.txt

```

gerçek ten gidip ilgili klasöre baktığımızda test.txt nin oluşmuş olduğunu görebiliriz.


dikkat edilmesi gereken konu şu. bu uygulama bir pod create ediyoruz. pod tek başına replication yapılamaz. Bunun için conttollerlar kullanılmalı (deployment, statefulset, replicaset, deamonset ...[etc](https://kubernetes.io/docs/concepts/workloads/controllers/)

eğer deployment kullanırsak ve replication ı birden fazla yaparsak ve mount işlemini de image ın bizden talep etttiği ENV değişkenri sayesinde deploymentt üzerinde veririsek tek bir volume createt edilip oluşturulan pod lara paylaştırılır. bunu test ettmek için alttaki kımutları çalıştırıyoruz.


**podları filtrelemek için**
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/


```
$ kubectl create -f files/dynamic-pvc-nfs-for-nginx.yaml

$ kubectl create -f files/dynamic-nfs-nginx.yaml

# daha sonra deployment ın pod listesini alıyoruz.

$ kubectl get pod
# şu üç taneden birine girip bir doya creatte ettikten sonra hem gerçek nfs hemde ttüm podlarda aynı klasöre baktığımızda dosyayı görebiliriz.

NAME                                        READY   STATUS    RESTARTS   AGE
curl                                        1/1     Running   0          37h
dynamic-busybox                             1/1     Running   4          44m
dynamic-pvc-nginx-deploy-56478c6994-cxjk9   1/1     Running   0          27m
dynamic-pvc-nginx-deploy-56478c6994-mq2cr   1/1     Running   0          27m
dynamic-pvc-nginx-deploy-56478c6994-pcnxm   1/1     Running   0          27m

```


dosyayı ilk podda create edelim.

```
# kubectl exec -it dynamic-pvc-nginx-deploy-56478c6994-cxjk9 -- sh
# touch /usr/share/nginx/html/test.txt
```

buradan çıkıp ilgili NFS klasöne gidecek olursak dosyanın yaıldığını görebiliriz.

sırayla diğer podlarda aynı klasöre gidip bakarak olursak oralarda da doya görülebilir.


```
$ kubectl exec -it dynamic-pvc-nginx-deploy-56478c6994-mq2cr -- sh

$ ls /usr/share/nginx/html/


$ kubectl exec -it dynamic-pvc-nginx-deploy-56478c6994-pcnxm -- sh

$ ls /usr/share/nginx/html/

```


### Resources

- https://www.youtube.com/watch?v=AavnQzWDTEk
- https://www.youtube.com/watch?v=I9GMUn15Nes&list=PL34sAs7_26wNBRWM6BDhnonoA5FMERax0&index=20
- https://blog.exxactcorp.com/deploying-dynamic-nfs-provisioning-in-kubernetes/
- https://developer.ibm.com/tutorials/add-nfs-provisioner-to-icp/
- https://medium.com/@myte/kubernetes-nfs-and-dynamic-nfs-provisioning-97e2afb8b4a9