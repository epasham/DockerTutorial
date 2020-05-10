kybernetesde ki pod a benzer birşey burada task olara geçiyor.


![swarm diagram](files/services-diagram.png)


#### Tasks and scheduling
A task is the atomic unit of scheduling within a swarm. When you declare a desired service state by creating or updating a service, the orchestrator realizes the desired state by scheduling tasks. For instance, you define a service that instructs the orchestrator to keep three instances of an HTTP listener running at all times. The orchestrator responds by creating three tasks. Each task is a slot that the scheduler fills by spawning a container. The container is the instantiation of the task. If an HTTP listener task subsequently fails its health check or crashes, the orchestrator creates a new replica task that spawns a new container.

![task](files/service-lifecycle.png)




### Özellikleri

- __Cluster management integrated with Docker Engine:__ Use the Docker Engine CLI to create a swarm of Docker Engines where you can deploy application services. You don’t need additional orchestration software to create or manage a swarm.
- __Decentralized design:__ Instead of handling differentiation between node roles at deployment time, the Docker Engine handles any specialization at runtime. You can deploy both kinds of nodes, managers and workers, using the Docker Engine. This means you can build an entire swarm from a single disk image.
- __Declarative service model:__ Docker Engine uses a declarative approach to let you define the desired state of the various services in your application stack. For example, you might describe an application comprised of a web front end service with message queueing services and a database backend
- __Scaling:__ For each service, you can declare the number of tasks you want to run. When you scale up or down, the swarm manager automatically adapts by adding or removing tasks to maintain the desired state.
- __Desired state reconciliation:__ The swarm manager node constantly monitors the cluster state and reconciles any differences between the actual state and your expressed desired state. For example, if you set up a service to run 10 replicas of a container, and a worker machine hosting two of those replicas crashes, the manager creates two new replicas to replace the replicas that crashed. The swarm manager assigns the new replicas to workers that are running and available
- __Multi-host networking:__ You can specify an overlay network for your services. The swarm manager automatically assigns addresses to the containers on the overlay network when it initializes or updates the application.
- __Service discovery:__ Swarm manager nodes assign each service in the swarm a unique DNS name and load balances running containers. You can query every container running in the swarm through a DNS server embedded in the swarm.
- __Load balancing:__ You can expose the ports for services to an external load balancer. Internally, the swarm lets you specify how to distribute service containers between nodes
- __Secure by default:__ Each node in the swarm enforces TLS mutual authentication and encryption to secure communications between itself and all other nodes. You have the option to use self-signed root certificates or certificates from a custom root CA.
- __Rolling updates:__ At rollout time you can apply service updates to nodes incrementally. The swarm manager lets you control the delay between service deployment to different sets of nodes. If anything goes wrong, you can roll back to a previous version of the service.


### Commands

- docker node https://docs.docker.com/engine/reference/commandline/node/
- docker service https://docs.docker.com/engine/reference/commandline/service/
- docker swarm  https://docs.docker.com/engine/reference/commandline/swarm/


#### dcoker node

Command	Description

- docker node demote: 	Demote one or more nodes from manager in the swarm
- docker node inspect:	Display detailed information on one or more nodes
- docker node ls:	List nodes in the swarm
- docker node promote:	Promote one or more nodes to manager in the swarm
- docker node ps: 	List tasks running on one or more nodes, defaults to current node
- docker node rm:	Remove one or more nodes from the swarm
- docker node update: 	Update a node

#### docker service

Child commands

Command	Description

- docker service create:	Create a new service
- docker service inspect:	Display detailed information on one or more services
- docker service logs:	Fetch the logs of a service or task
- docker service ls:	List services
- docker service ps:	List the tasks of one or more services
- docker service rm:	Remove one or more services
- docker service rollback:	Revert changes to a service’s configuration
- docker service scale:	Scale one or multiple replicated services
- docker service update:	Update a service

#### docker swarm

Child commands

Command	Description

- docker swarm ca:	Display and rotate the root CA
- docker swarm init:	Initialize a swarm
- docker swarm join:	Join a swarm as a node and/or manager
- docker swarm join-token:	Manage join tokens
- docker swarm leave:	Leave the swarm
- docker swarm unlock:	Unlock swarm
- docker swarm unlock-key:	Manage the unlock key
- docker swarm update:	Update the swarm