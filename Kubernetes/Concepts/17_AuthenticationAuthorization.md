 
Kubernets de 2 rip kullanıcı var service kullanıcısı ve normal kullanıcı.

Kubernetes sadece service kullanıcısı tanımı sunmaktaır ve bunun resource olarak bir karşılığı vardır. 

Diğer normal kullanıcılar için 3 farklı yöntem sunmakatadır

- an administrator distributing private keys
- a user store like Keystone or Google Accounts
- a file with a list of usernames and passwords

Noırmak kullanıcı bişr API çaırarak da oluşturulamaz.  Ancak cluster ın CA sertifikası ile oluşturulmuş subject kısmında kullanıcı adı yazılı bir sertifika sunarak işlemler yapabilir.  Kuberntes'de tanımlı RBAC ile belirlenmiş yetkileriyle de işlemlerini yapabilir.

Service Accountları ise kubernetes api yardımıyla oluşturlabilir.


### Authentication strategies

- [X509 Client Certs](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#x509-client-certs) - [linkk2 detaylı](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/)
- [Static Token File](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#static-token-file)
- [Bootstrap Tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#bootstrap-tokens) - [link2 detaylı](https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/)
- [Service Account Tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#service-account-tokens)
- [OpenID Connect Tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens)
- [Webhook Token Authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication)
- [Authenticating Proxy](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#authenticating-proxy)


### User impersonation

https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation



### Normal User olauşturma ve yetkilendirme



- **Step 1: Create the office namespace**
Execute the kubectl create command to create the namespace (as the admin user):

```bash
kubectl create namespace office
```

- **Step 2: Create the user credentials**

As previously mentioned, Kubernetes does not have API Objects for User Accounts. Of the available ways to manage authentication (see Kubernetes official documentation for a complete list), we will use OpenSSL certificates for their simplicity. The necessary steps are:

- Create a private key for your user. In this example, we will name the file employee.key:
```bash
openssl genrsa -out employee.key 2048
```

- Create a certificate sign request employee.csr using the private key you just created (employee.key in this example). Make sure you specify your username and group in the -subj section (CN is for the username and O for the group). As previously mentioned, we will use employee as the name and bitnami as the group:

```bash
openssl req -new -key employee.key -out employee.csr -subj "/CN=employee/O=bitnami"
```

- Locate your Kubernetes cluster certificate authority (CA). This will be responsible for approving the request and generating the necessary certificate to access the cluster API. Its location is normally /etc/kubernetes/pki/. In the case of Minikube, it would be ~/.minikube/. Check that the files ca.crt and ca.key exist in the location.

- Generate the final certificate employee.crt by approving the certificate sign request, employee.csr, you made earlier. Make sure you substitute the CA_LOCATION placeholder with the location of your cluster CA. In this example, the certificate will be valid for 500 days:

```bash
openssl x509 -req -in employee.csr -CA CA_LOCATION/ca.crt -CAkey CA_LOCATION/ca.key -CAcreateserial -out employee.crt -days 500
```

- Save both employee.crt and employee.key in a safe location (in this example we will use /home/employee/.certs/).

- Add a new context with the new credentials for your Kubernetes cluster. This example is for a Minikube cluster but it should be similar for others:

```bash
kubectl config set-credentials employee --client-certificate=/home/employee/.certs/employee.crt  --client-key=/home/employee/.certs/employee.key

kubectl config set-context employee-context --cluster=minikube --namespace=office --user=employee
```


Now you should get an access denied error when using the kubectl CLI with this configuration file. This is expected as we have not defined any permitted operations for this user.

```bash
kubectl --context=employee-context get pods
```

- **Step 3: Create the role for managing deployments**

Create a role-deployment-manager.yaml file with the content below. In this yaml file we are creating the rule that allows a user to execute several operations on Deployments, Pods and ReplicaSets (necessary for creating a Deployment), which belong to the core (expressed by "" in the yaml file), apps, and extensions API Groups:

```bash
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: office
  name: deployment-manager
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
  
```

Create the Role in the cluster using the kubectl create role command:

```bash
kubectl create -f role-deployment-manager.yaml
```

- **Step 4: Bind the role to the employee user**
Create a rolebinding-deployment-manager.yaml file with the content below. In this file, we are binding the deployment-manager Role to the User Account employee inside the office namespace:

```bash
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: deployment-manager-binding
  namespace: office
subjects:
- kind: User
  name: employee
  apiGroup: ""
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: ""

  ```
  
  
Deploy the RoleBinding by running the kubectl create command:

```bash
kubectl create -f rolebinding-deployment-manager.yaml
```

- **Step 5: Test the RBAC rule**
Now you should be able to execute the following commands without any issues:

```bash
kubectl --context=employee-context run --image bitnami/dokuwiki mydokuwiki
kubectl --context=employee-context get pods
```
If you run the same command with the --namespace=default argument, it will fail, as the employee user does not have access to this namespace.

```bash
kubectl --context=employee-context get pods --namespace=default
```
Now you have created a user with limited permissions in your cluster.


- https://cloudhero.io/creating-users-for-your-kubernetes-cluster



### Kısıtlı yetkili kullanıcı oluşturma 


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

3. **RoleBinding create ediyoruz**

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


sonuç oılarak pod lar listelenmiş olacak.









###  Service Account Oluşturma ve yetkilendirme




 
 
 ### Resources

- https://www.adaltas.com/en/2019/08/07/users-rbac-kubernetes/
- https://kubernetes.io/docs/reference/access-authn-authz/authentication/
