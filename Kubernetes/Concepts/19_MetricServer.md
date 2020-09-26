 
https://github.com/kubernetes-sigs/metrics-server



Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

Metrics Server collects resource metrics from Kubelets and exposes them in Kubernetes apiserver through Metrics API for use by Horizontal Pod Autoscaler and Vertical Pod Autoscaler. Metrics API can also be accessed by kubectl top, making it easier to debug autoscaling pipelines.

Metrics Server is not meant for non-autoscaling purposes. For example, don't use it to forward metrics to monitoring solutions, or as a source of monitoring solution metrics.

Metrics Server offers:

- A single deployment that works on most clusters (see Requirements)
- Scalable support up to 5,000 node clusters
- Resource efficiency: Metrics Server uses 0.5m core of CPU and 4 MB of memory per node

Use cases

You can use Metrics Server for:

- CPU/Memory based horizontal autoscaling (learn more about Horizontal Pod Autoscaler)
- Automatically adjusting/suggesting resources needed by containers (learn more about Vertical Pod Autoscaler)

Don't use Metrics Server when you need:

- Non-Kubernetes clusters
- An accurate source of resource usage metrics
- Horizontal autoscaling based on other resources than CPU/Memory

For unsupported use cases, check out full monitoring solutions like Prometheus.
