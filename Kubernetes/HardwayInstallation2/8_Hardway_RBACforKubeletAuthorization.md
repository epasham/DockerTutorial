### Role Based Authetication for Kubernetes Authorization

Bunu ayarlamamızdaki sebeplerden biri de Kube API server'ın worker node'lardaki kubelet'lere ulaşarak pod'lar hakkında bilgi toplmasını ve komutları çalıştırmasını sağlamaktır.

Kubeklet'lerin --authorization-mode parametresini webhood olarka ayarloyoruz. Webhook  authorization'u tanımlamak için SubjectAccessReview API'ni kullanır. Daha detaylı incelemek için [bu sayfaya](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules) bakınız.

Daha sonra rbac_kubelet_auth.yaml adnda bir dosya oluşturarak alttaki satırları içine kopyalıyoruz. Dosyayı files altındaki yml klasörüne oluşturacağım.

İnternette göreceğiniz bir çok kaynakta apiVersion  apiVersion: rbac.authorization.k8s.io/v1beta1 olarak versiyonlarnış. Bu kaynklar genelde Kubernetes 1.15 versiyonunu kullanıyor. Şuan rbac iççin v1 kullanımda olduğu için biz onu kulanıyor olacağız.

- [Konuyla ilgili oalrak şu dökümanı okuyabilirsiniz](https://kubernetes.io/blog/2017/10/using-rbac-generally-available-18/)
- [clusterRole ve version hakkında](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#clusterrole-example)

Burada kube API server a Kubelet üzerinde Cluster seviyesinde bir çok işlemi yapabilmesi için yetki vermiş oluyoruz.

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
```

Daha sonra ilgili yml dosyasını herhangi bir master (controller) node'a taşıyarak alttaki komutla konfigürayonu uguluyoruz.

```
$ sudo kubectl apply --kubeconfig admin_master.kubeconfig -f /home/kubernetes/yaml/rbac_kubelet_auth.yaml
```
bu komut aslında api server'ı kubernetes kullanıcısı olarak kubelet üzerinde işlem yapabilmek yetkilendiriyor.A Api servisinni service dosyasında --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem  parametresi bunu göstermektdir. Bu ndenle üstteki clusterRole' ü kubernetes kullanıcısına bağlamamız (bind) gerekmektedir.

bunun için yeni bir yml manifesto dosyası oluşturuyoruz. İlgili dosyayı rbac_kubelet_bind.yaml olarka files altındaki yml klasörüne .oluşturuyorum.

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
```


daha sonra herhangi bir master (controller) node'a kopyalarıp aşağıdaki komutla uyguluyoruz.

```
$ sudo kubectl apply --kubeconfig admin_master.kubeconfig -f /home/kubernetes/yaml/rbac_kubelet_bind.yaml
```



- https://stackoverflow.com/questions/52744289/granting-a-kubernetes-service-account-permissions-for-secrets
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
- https://v1-16.docs.kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
- https://github.com/fabric8io/fabric8/issues/6840
- https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/
- https://kubernetes.io/blog/2017/10/using-rbac-generally-available-18/
- https://stackoverflow.com/questions/49295805/no-api-token-found-for-service-account-default