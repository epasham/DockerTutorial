1. CONTEXT

https://docs.docker.com/engine/context/working-with-contexts/


This guide shows how contexts make it easy for a single Docker CLI to manage multiple Swarm clusters, multiple Kubernetes clusters, and multiple individual Docker nodes.

A single Docker CLI can have multiple contexts. Each context contains all of the endpoint and security information required to manage a different cluster or node. The docker context command makes it easy to configure these contexts and switch between them.

As an example, a single Docker client on your company laptop might be configured with two contexts; dev-k8s and prod-swarm. dev-k8s contains the endpoint data and security credentials to configure and manage a Kubernetes cluster in a development environment. prod-swarm contains everything required to manage a Swarm cluster in a production environment. Once these contexts are configured, you can use the top-level docker context use context-name to easily switch between them.

- The anatomy of a context
A context is a combination of several properties. These include:

Name

- Endpoint configuration
- TLS info
- Orchestrator
- 
The easiest way to see what a context looks like is to view the default context.
``` shell
$ docker context ls
NAME          DESCRIPTION     DOCKER ENDPOINT                KUBERNETES ENDPOINT      ORCHESTRATOR
default *     Current...      unix:///var/run/docker.sock                             swarm
```