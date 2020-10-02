### Ön Gereksinimler
- MetalLb kurulmuş olmalı
- Dynamic Persistant Volume kurulmuş olmalı
- third party service account tokens oluşturmaya izin verilmeli. istioctl kullandığımız için kurulmda kendisi otomatik olarak daha az güvenli olan versiyonu kullanıyor eğer thirt party ye izin verilmediyse. kaynak : https://istio.io/latest/docs/ops/best-practices/security/#configure-third-party-service-account-tokens


- Third party tokens, which have a scoped audience and expiration.
- First party tokens, which have no expiration and are mounted into all pods.

1. **öncelikle istio yu download ediyoruz** 

https://istio.io/latest/docs/setup/getting-started/#download

download ederken version numarası belirtiyoruz.

download ettikten sonra klasörü uygun bir yere kopyalıoyoruz.


# https://istio.io/downloadIstio | ISTIO_VERSION=1.6.8 sh -.

```
$ curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.7.2 sh -
$ cp -R $PWD/istio-1.7.2 ~/Projects/
```

klasördeki executable a bağımlılığımız olmaması için bin klasörüne kopyalıyoruz

```
$ sudo cp ~/Projects/istio-1.7.2/bin/istioctl /usr/local/bin/
$ istioctl version

#sonuç

no running Istio pods in "istio-system"
1.7.2

```

2. **Kurulum öncesi kontroller için verify yapılır**


```
# istioctl verify-install is no longer a valid command (since 1.6) replaced by istioctl x precheck

$ istioctl x precheck
# sonuç

Checking the cluster to make sure it is ready for Istio installation...

#1. Kubernetes-api
-----------------------
Can initialize the Kubernetes client.
Can query the Kubernetes API Server.

#2. Kubernetes-version
-----------------------
Istio is compatible with Kubernetes: v1.17.9.

#3. Istio-existence
-----------------------
Istio will be installed in the istio-system namespace.

#4. Kubernetes-setup
-----------------------
Can create necessary Kubernetes configurations: Namespace,ClusterRole,ClusterRoleBinding,CustomResourceDefinition,Role,ServiceAccount,Service,Deployments,ConfigMap. 

#5. SideCar-Injector
-----------------------
This Kubernetes cluster supports automatic sidecar injection. To enable automatic sidecar injection see https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#deploying-an-app

-----------------------
Install Pre-Check passed! The cluster is ready for Istio installation.

```

kurulum sonraı check edebilmek için instaall komutunun gerçekte profile göre oluşturduğu manifest doyası kopyası alınır kurulumdan sonra kontrol için.
```
$ mkir ~/Projects/istio-1.7.2/temp
$  istioctl manifest generate > ~/Projects/istio-1.7.2/temp/generated-manifest.yaml

# kurulum bittikten sonra kontrol için
$ istioctl verify-install -f ~/Projects/istio-1.7.2/temp/myistiomanifest.yaml 

```


3. **Kurulum için profillere bakılır.**


https://istio.io/latest/docs/setup/additional-setup/config-profiles/

istio klasöründe şu path'de "manifests/profiles/" ilgili profiller görülebilir. Her profilde bazı özellikler kurulur bazıları kurulmaz.

configurasyonları customize etmek için : https://istio.io/latest/docs/setup/install/istioctl/#customizing-the-configuration

**Istio Componentleri**

- base
- pilot
- proxy
- telemetry
- policy
- ingressGateways
- egressGateways
- cni

**Her bileşenin, aşağıdaki ayarların değiştirilmesine izin veren bir KubernetesResourceSpec vardır.**

 Özelleştirilecek ayarı belirlemek için bu listeyi kullanın:

- Resources
- Readiness probes
- Replica count
- HorizontalPodAutoscaler
- PodDisruptionBudget
- Pod annotations
- Service annotations
- ImagePullPolicy
- Priority class name
- Node selector
- Affinity and anti-affinity
- Service
- Toleration
- Strategy
- Env

https://kubernetes.io/docs/concepts/

örneğin alttaki yaml dosyası pilot için autoscale ayarlarını güncellemektedir.

```
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    pilot:
      k8s:
        resources:
          requests:
            cpu: 1000m # override from default 500m
            memory: 4096Mi # ... default 2048Mi
        hpaSpec:
          maxReplicas: 10 # ... default 5
          minReplicas: 2  # ... default 1
        nodeSelector:
          master: "true"
        tolerations:
        - key: dedicated
          operator: Exists
          effect: NoSchedule
        - key: CriticalAddonsOnly
          operator: Exists
```



**Hazır Profiller**

```
$ istioctl profile list

# sonuç

Istio configuration profiles:
    remote
    default
    demo
    empty
    minimal
    preview

```


 - default: enables components according to the default settings of the IstioOperator API. This profile is recommended for production deployments and for primary clusters in a multicluster mesh. You can display the default setting by running the command istioctl profile dump.

 - demo: configuration designed to showcase Istio functionality with modest resource requirements. It is suitable to run the Bookinfo application and associated tasks. This is the configuration that is installed with the quick start instructions.
    This profile enables high levels of tracing and access logging so it is not suitable for performance tests.

 - minimal: the minimal set of components necessary to use Istio’s traffic management features.

 - remote: used for configuring remote clusters of a multicluster mesh.

 - empty: deploys nothing. This can be useful as a base profile for custom configuration.

 - preview: the preview profile contains features that are experimental. This is intended to explore new features coming to Istio. Stability, security, and performance are not guaranteed - use at your own risk.

The components marked as X are installed within each profile:

||default|demo|minimal|remote|
|--|--|--|--|--|
|Core components|||||
|istio-egressgateway|-|X|-|-|
|istio-ingressgateway|X|X|-|-|
|istiod|X|X|X|-|



dökümana göre production ortamı için uygun olan profil default profili. Default profilde zaten bu profil.  







4. **Default Profili ile kurulum yapılır**

```
$ istioctl install --set profile=default
```

### Kurulum Sonrası

daha önce aldığımız manifest doyasıo kullanılır

```
# kurulum bittikten sonra kontrol için
$ istioctl verify-install -f ~/Projects/istio-1.7.2/temp/myistiomanifest.yaml 
```





### Troubleshooting

**ingress ayağa kalkmaması**

- https://github.com/istio/istio/issues/25205
- https://stackoverflow.com/questions/57638780/kubernetes-istio-ingress-gateway-responds-with-503-always
- https://github.com/istio/istio/issues/22800
- https://github.com/istio/istio/issues/23487
- https://github.com/istio/istio/issues/14095
- https://github.com/istio/istio/issues/14205
- https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/



### Kaldırmak için

```

# samples kurduysak once onlar kaldırılır
$ kubectl delete -f samples/addons

#isito kaldırlır 
$ istioctl manifest generate --set profile=default | kubectl delete --ignore-not-found=true -f -

# The istio-system namespace is not removed by default. If no longer needed, use the following command to remove it:

# namespace kaldırlır.
$ kubectl delete namespace istio-system

# eğer uzun süre takılı kalırsa aşağıdaki adımlar yapılır

$ kubectl get namespace istio-system -o json > ~/Projects/istio-1.7.2/temp.json

$ nano ~/Projects/istio-1.7.2/temp.json

# spec içimdeki array boşaltılı yani kubernetes silinir
#    "spec": {
#        "finalizers": [
#            "kubernetes"
#        ]
#    },


$ kubectl replace --raw "/api/v1/namespaces/istio-system/finalize" -f ~/Projects/istio-1.7.2/temp.json


```



### Resources

- https://www.youtube.com/watch?v=wdusXMYeddg
- https://azure.kocsistem.com.tr/en/blog/istio-kurulum-ve-trafik-yonetimi
- https://medium.com/better-programming/how-to-authorize-non-kubernetes-clients-with-istio-on-your-k8s-cluster-8a90fe95b137

