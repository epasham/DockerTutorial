
#### ConfigMaps

A ConfigMap is an API object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.


__ConfigMaps and Pods__

You can write a Pod spec that refers to a ConfigMap and configures the container(s) in that Pod based on the data in the ConfigMap. The Pod and the ConfigMap must be in the same namespace.

örnek
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  # property-like keys; each key maps to a simple value
  player_initial_lives: 3
  ui_properties_file_name: "user-interface.properties"
  #
  # file-like keys
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
```

There are four different ways that you can use a ConfigMap to configure a container inside a Pod:

- Command line arguments to the entrypoint of a container
- Environment variables for a container
- Add a file in read-only volume, for the application to read
- Write code to run inside the Pod that uses the Kubernetes - API to read a ConfigMap

Here’s an example Pod that uses values from game-demo to configure a Pod:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
spec:
  containers:
    - name: demo
      image: game.example/demo-game
      env:
        # Define the environment variable
        - name: PLAYER_INITIAL_LIVES # Notice that the case is different here
                                     # from the key name in the ConfigMap.
          valueFrom:
            configMapKeyRef:
              name: game-demo           # The ConfigMap this value comes from.
              key: player_initial_lives # The key to fetch.
        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name
      volumeMounts:
      - name: config
        mountPath: "/config"
        readOnly: true
  volumes:
    # You set volumes at the Pod level, then mount them into containers inside that Pod
    - name: config
      configMap:
        # Provide the name of the ConfigMap you want to mount.
        name: game-demo
```

#### Best Practices

- Naked Pods crate etmemek lazım çünkü hata durumlarında schedule edilemiyorlar. 

__service ler için best practice ler__

- servisleri backend workoad lardan (eployments or replicaset) önce oluşturmak lazım. çünki pod lar ayağa kalkarken örneğin environment variable ları okuyor. onlar hazır olmalı
- cluster add onlaradn DNS kullanılmalı. böylece bütün pod lar service leri çözebilir.
- gerekmedikçe posların hostPort bilgisi belitmemek lazım. eğer belirtilirse pod ların schedule alanını daratmış oluruz.

eğer debug gerekiyorsa, yani bu durumdan dolayı belirtilmek isteniyoras bunun yerine apiserver proxy veya kubectl port-forward kullanılmalıdır.

eğer açıkça pod portu belirtileceksebunun için öncelikle NodePort kulanılmaya çalışılmalı hostPort yerine

- hostPort da üstte belirtilen nedenlerden dolayı hostNetWork kulanılmamalı.
  
__label lar için best practice leri__

- Define and use labels that identify semantic attributes of your application or Deployment, such as { app: myapp, tier: frontend, phase: test, deployment: v3 }. You can use these labels to select the appropriate Pods for other resources; for example, a Service that selects all tier: frontend Pods, or all phase: test components of app: myapp. See the guestbook app for examples of this approach.


__Container Pull Policy__

- imagePullPolicy: IfNotPresent: the image is pulled only if it is not already present locally.

- imagePullPolicy: Always: the image is pulled every time the pod is started.

- imagePullPolicy is omitted and either the image tag is :latest or it is omitted: Always is applied.

- imagePullPolicy is omitted and the image tag is present but not :latest: IfNotPresent is applied.

- imagePullPolicy: Never: the image is assumed to exist locally. No attempt is made to pull the image.

__kubectl__

- Use kubectl apply -f [directory]. This looks for Kubernetes configuration in all .yaml, .yml, and .json files in [directory] and passes it to apply.

- Use label selectors for get and delete operations instead of specific object names. See the sections on label selectors and using labels effectively.

- Use kubectl run and kubectl expose to quickly create single-container Deployments and Services. See Use a Service to Access an Application in a Cluster for an example

