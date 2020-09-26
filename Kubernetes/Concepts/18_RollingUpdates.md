 
https://medium.com/@IlyasKeser/deployment-rolling-update-and-rollback-with-kubernetes-ab8707dc1149

https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/workloads/controllers/deployment/

https://learnk8s.io/kubernetes-rollbacks

https://kubernetes.io/docs/concepts/containers/images/#updating-images


Updating Images

The default pull policy is IfNotPresent which causes the kubelet to skip pulling an image if it already exists. If you would like to always force a pull, you can do one of the following:

- set the imagePullPolicy of the container to Always.
- omit the imagePullPolicy and use :latest as the tag for the image to use.
- omit the imagePullPolicy and the tag for the image to use.
- enable the AlwaysPullImages admission controller.

When imagePullPolicy is defined without a specific value, it is also set to Always.

