### Rook Nedir

Rook turns distributed storage systems into self-managing, self-scaling, self-healing storage services. It automates the tasks of a storage administrator: deployment, bootstrapping, configuration, provisioning, scaling, upgrading, migration, disaster recovery, monitoring, and resource management.

Aslşında farklı storage sistemlerini kubernetes e soyutlamak için kullanılır. Örneğin NFS, GlusaterFs, FlexFs, Cepf etc gibi bir çopk storage sistemini Rook üzerinden kubernetes e sunmak mümkün. Ancak piyasada ençok Ceph ile kullanıldığından sadece onunla çalışabiliyormuş izlenimi var.













### Kurulum

- ceph resmi sayfası: https://docs.ceph.com/en/latest/install/
- CEPH hakkında daha fazla bilgi için : https://github.com/muratcabuk/Notes/blob/master/StorageSystems/ceph.md
- https://github.com/rook/rook/tree/master/Documentation

ceph ayrıca kubernets e rookdan bağımsız olark container olarak da kurulabilir. : https://github.com/ceph/ceph-container



Rook deploys and manages Ceph clusters running in Kubernetes, while also enabling management of storage resources and provisioning via Kubernetes APIs. We recommend Rook as the way to run Ceph in Kubernetes or to connect an existing Ceph storage cluster to Kubernetes.

- Rook only supports Nautilus and newer releases of Ceph.
- Rook is the preferred method for running Ceph on Kubernetes, or for connecting a Kubernetes cluster to an existing (external) Ceph cluster.
- Rook supports the new orchestrator API. New management features in the CLI and dashboard are fully supported.


rook resmi sayfası: https://rook.io/docs/rook/v1.4/ceph-storage.html




### Backup & Restore

**Rook ve Ceph özel araçlar**
- https://github.com/rook/rook/blob/master/Documentation/ceph-disaster-recovery.md
- https://github.com/wamdam/backy2
- http://ceph.com/community/blog/tag/backup/
- http://ceph.com/docs/giant/rbd/rbd-snapshot/
- http://t3491.file-systems-ceph-user.file-systemstalk.us/backups-t3491.html
- 


**Genel Araçlar**
- https://github.com/vmware-tanzu/velero
- https://github.com/stashed/stash



- https://www.bookstack.cn/read/rook-1.0-en/8b1c5331c3201feb.md (eski bir version ama güzel anlatımı var)
- https://www.youtube.com/watch?v=wIRMxl_oEMM 
- https://medium.com/devopsturkiye/rook-nedir-rook-ile-kubernetes-ortam%C4%B1n%C4%B1za-ceph-storage-entegrasyonu-cabd699d568e
