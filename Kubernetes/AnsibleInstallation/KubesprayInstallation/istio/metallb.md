Metallb neden gerekli detaylar için [şu sayfaya](loadbalance_vs_ingress_vs_ServiceMesh.md) bakınız.

### Kurulum

biz version 0.9.3 ü kullanıyor olacağız.

şu sayfaları takip ediyor olacağız

- https://metallb.universe.tf/installation/
- https://starkandwayne.com/blog/k8s-and-metallb-a-loadbalancer-for-on-prem-deployments/
- https://dev.to/ozorest/local-nlb-for-kubernetes-54h9



1. öncelikle configmap ayarımızda mode un ipvs olduğundan emin oluyoruz.

If you’re using kube-proxy in IPVS mode, since Kubernetes v1.14.2 you have to enable strict ARP mode.

Note, you don’t need this if you’re using kube-router as service-proxy because it is enabling strict arp by default.

```
$ kubectl edit configmap -n kube-system kube-proxy

# sonuç olmalı değilse atrictARP yi true yapıyoruz.

apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true

```
2. daha sonra alttaki 2 manifest i apply yapıyoruz

```
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
```

3. sadece ilk kurulumda bir kez çalıştırılacak olan secret i create ediyoruz.

```
$ kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

buraya kadar yapıtıklarımıla aşağıdakileri kurmuş olduk.


This will deploy MetalLB to your cluster, under the metallb-system namespace. The components in the manifest are:

- The metallb-system/controller deployment. This is the cluster-wide controller that handles IP address assignments.
- The metallb-system/speaker daemonset. This is the component that speaks the protocol(s) of your choice to make the services reachable.
- Service accounts for the controller and speaker, along with the RBAC permissions that the components need to function.

4. şimdi sıra condigmap in konfigürayonuna.

bunun için 2 yöntem var 

- [Layer 2 Configuration](https://metallb.universe.tf/configuration/#layer-2-configuration): basit yöntem.  
- [BGP configuration](https://metallb.universe.tf/configuration/#bgp-configuration): karmaşık ancak daha hızlı ve sağlam yöntem.
    - https://www.growse.com/2019/04/13/at-home-with-kubernetes-metallb-and-bgp.html
    - https://medium.com/@ipuustin/using-metallb-as-kubernetes-load-balancer-with-ubiquiti-edgerouter-7ff680e9dca3


eğer BGP tercih edek olursanız [şu sayfayı](https://metallb.universe.tf/configuration/calico/) da check ediniz. Calico da BGP kullandığı için bir iki durumla karşılaşılabilir.




biz kolay yöntemi tercih ediyor olcağız. bunun için [Layer 2 Configuration](https://metallb.universe.tf/configuration/#layer-2-configuration) sayfasını takip ediyor olacağız.


ömcelikle node larımızın aldığı iplere bakıp çalışmayacak bir aralığı metallb kü-mesine vereceğiz. bununiçin alttkai komutu çalıştırıyoruz.

```
$ kubectl get nodes -o wide
# sonuç

NAME    STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME                                     │bernetes-dashboard-c9dd89c59-rn9qr","endpoint":"eth0","ipNetworks":["10.233.92.4/32"],"profiles"
node1   Ready    master   3d2h   v1.17.9   10.0.1.5      <none>        Ubuntu 18.04.5 LTS   5.4.0-1025-azure   docker://18.9.7                                       │:["kns.kuberadmiadminuser@node2:/etc/ssl$ sudo ETCDCTL_API=3  etcdctl --cert=/etc/ssl/etcd/ssl/n
node2   Ready    master   3d2h   v1.17.9   10.0.1.6      <none>        Ubuntu 18.04.5 LTS   5.4.0-1025-azure   docker://18.9.7                                       │adminuser@node2:/etc/ssl$ sudo ETCDCTL_API=3  etcdctl --cert=/etc/ssl/etadminuser@node2:/etc/ssl
node3   Ready    master   3d2h   v1.17.9   10.0.1.7      <none>        Ubuntu 18.04.5 LTS   5.4.0-1025-azure   docker://18.9.7
```

görüldüğü üzere aiplerimiz 5 den 7 ye kadar. azure da zaten ip aralığını subnet oluşturuken address_prefix: "10.0.1.0/24" şeklinde belirtmiştik. bu 254 adet ip dağıtabilceğimizi gösteriyor. bizde 200 - 230 araasını verdik



```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.0.1.200-10.0.1.230
```

görüldüğü üze birden fazla adres pool oluşturulabiliyor. böylece deploy doysmıza ufak bir eklemyle istediğimiz ip havuzundan ip alabiliriz. bu public ip de olabilir tabii sunucuda tanımlıysa.

- örnek kullanım [link](https://metallb.universe.tf/usage/#requesting-specific-ips)

metallb.universe.tf/address-pool: production-public-ips bu kısım istenilen poolu gösteriyor.

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    metallb.universe.tf/address-pool: production-public-ips
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
```


bu konfigürasyonu da alttaki komutla filers altındaki ilgili dosyayı çağırarak yapıyoruz.

```
$ kubectl create -f files/metallblayer2conf.yaml

```

daha sonra check ediyoruz

```
$ kubectl describe configmap -n metallb-system
# sonuç

address-pools:
- name: default 
  protocol: layer2   
  addresses:                                                                                                               
  - 10.0.1.200-10.0.1.230

```

5. bir pod oluşturuyoruz


test ekmek için rmek uygulamayı creatte ediyoruz.

```
$ kubectl apply -f files/metallbnginx.yaml
```

daha sonra servisi describe edip worker nodelardan birinden  servisin external ip sine ping atacak olursak cevap aldığımız görebiliriz.

peki her web sayfa için bu şekilde ip dağıttabilirmiyiz? farklı senaryolarda belki olabilir ancak yönetmek baya zor olur bu şekilde. işte bu nedenle arka tarafta ingressi api gateway veya istio service mesh gibi araçlara ihtiyaç var. 

örneğin ingress servisi için loadbalancer ip si kullanıp, ingress servisimiz için metallb den bi ip alıp tüm istekleri bu ip ye yönlendirirsek dışarıdan ingress e de kural girip hangi domain i,çin hangi servisin çağrılacağını belirlediğimizde sistem çalışıyor olacak.

bu durumda aynı anda istenirse isttio service mesh ve nginx ingress çalıştırılabilir. 

ancak buna gerek yok çünki istio üzerinde zaten nginx ingress kadar güçlü olmasada bir ingress geliyor zaten o  da kullanılabilir.


