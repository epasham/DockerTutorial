## calico için ön bilgiler



#### ETCD bilgileri

- https://rancher.com/blog/2019/2019-01-29-what-is-etcd/
- https://docs.projectcalico.org/getting-started/clis/calicoctl/configure/etcd


**herbir node daki adresler**

- name=etcd1 peerURLs=https://10.0.1.5:2380 clientURLs=https://10.0.1.5:2379 isLeader=true
- name=etcd2 peerURLs=https://10.0.1.6:2380 clientURLs=https://10.0.1.6:2379 isLeader=false
- name=etcd3 peerURLs=https://10.0.1.7:2380 clientURLs=https://10.0.1.7:2379 isLeader=false


**alttaki kullanım hatalı adlında** sebebi ise bu sertifikalar her makinada etcd clusterına bağlanırken kullanılan serfika. etcdctl ile etcd de adminlik işler yapmak için değil.

- sudo etcdctl --cert=/etc/ssl/etcd/ssl/member-node2.pem --key-file=/etc/ssl/etcd/ssl/member-node2-key.pem --ca-file=/etc/ssl/etcd/ssl/ca.pem --endpoints=https://10.0.1.7:2380 ls



**Biz nnode larda bağlanırken ETCD ye alttttakini kullanıyoruz. sebebi ise mutual tls (mtls). etcdctl ile bağlanırken etcd ye bağlanıyoruz bu nedenle etcd servisinin admin serttifikalarını kullanıyoruz.**


node 2 de iken çalıştırma şeklimiz bu şekilde. backup resore ederken de bu sertifikaları kullanmalıyız.

- sudo ETCDCTL_API=3  etcdctl --cert=/etc/ssl/etcd/ssl/node-node2.pem --key=/etc/ssl/etcd/ssl/node-node2-key.pem   get --prefix /c


- sudo etcdctl --cert-file=/etc/ssl/etcd/ssl/admin-node2.pem --key-file=/etc/ssl/etcd/ssl/admin-node2-key.pem --ca-file=/etc/ssl/etcd/ssl/ca.pem --endpoints=https://127.0.0.1:2379 ls

**API v2 Commands** ancak biz v3 ü kullanıyoruz

http://manpages.ubuntu.com/manpages/eoan/man1/etcdctl.1.html#commands%20v2




### Calico






- https://kubespray.io/#/docs/calico
- https://docs.projectcalico.org/getting-started/clis/calicoctl/configure/etcd
- https://www.tigera.io/blog/configuring-route-reflectors-in-calico/
- https://docs.projectcalico.org/reference/architecture/overview
- https://www.tigera.io/blog/configuring-route-reflectors-in-calico/
- https://docs.projectcalico.org/networking/bgp
- https://docs.projectcalico.org/reference/architecture/design/
- https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises
- https://docs.projectcalico.org/reference/architecture/data-path

