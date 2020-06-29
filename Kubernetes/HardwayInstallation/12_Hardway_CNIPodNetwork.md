Docker CNI kullanmaz CNM kullanır (docker network Model). Ancak CNI docker da da istenirse kullanılabşilir. docker --network parametresi none yapılır ve alttaki komutla cotaineris için bridge tanımlaması yapılır.

```
docker run [containerid] /var/run/nets/[containerid]
```
zaten bu sayede docker CNI ile (dolayısıyla kubernetes ile) çalışabilir hale gelmiş olur.





__Calico Kurulumu__

Kuruluma başlamadan önce ileride hata olabilir, belki kapalı kalmış olabilir düşüncesiyle alttaki komutla forwarding kapalıysa açık duruma getiriyoruz

```
$ sudo sysctl net.ipv4.conf.all.forwarding=1
```

Kurulum için [şu sayfayı](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises) takip ediyor olacağım.

öncelike [şu adresten](https://docs.projectcalico.org/manifests/calico.yaml) calico.yaml dosyamızı indirip dosya içinde CALICO_IPV4POOL_CIDR değişkeninin açıklama satırlarını kaldırarak değerini kendi pod network bloğumuz (10.200.0.0/16 ) ile değiştiriyoruz.

daha sonra alttaki komutu ister local kubectl ile istersek master ve worker node'lar dan biri üzerinde çalıştırıyoruz.

ben master1 üzerinde çalıştırıyorum. bu nedenle calico.yaml dosyamı master1 node'una kopyalıyorum.

```
$ kubectl apply --kubeconfig /home/kubernetes/kubeconfigs/admin.kubeconfig -f /home/kubernetes/yaml/calico.yaml
```
daha sonra calicoctl kurumunu yapıyor olacağız.

biz etcd kullanığımız için [şu adresten](https://docs.projectcalico.org/manifests/calicoctl-etcd.yaml) calicoctl-etcd.yaml dosyasını indirip msater1 node'una taşıyoruz.

daha sonra master1 node'unda alttaki komutla kurlumu yapıyoruz.

```
$ kubectl apply --kubeconfig /home/kubernetes/kubeconfigs/admin.kubeconfig -f /home/kubernetes/yaml/calicoctl-etcd.yaml

```

```
$ kubectl exec -ti -n kube-system calicoctl -- /calicoctl get profiles -o wide

```
