### Silinmeyen namespace ler için çözüm

```
$ kubectl get namespace (namespace adı gelecek) -o json > temp.json

$ nano temp.json

# spec içimdeki array boşaltılı yani kubernetes silinir
#    "spec": {
#        "finalizers": [
#            "kubernetes"
#        ]
#    },


$ kubectl replace --raw "/api/v1/namespaces/(namaspace adi gelecek)/finalize" -f ./temp.json


```


### Network

- https://www.engineerbetter.com/blog/debugging-kubernetes-networking/
