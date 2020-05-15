https://kubernetes.io/docs/concepts/configuration/secret/


#### Creating a Secret manually

```
echo -n 'admin' | base64

The output is similar to:

YWRtaW4=

echo -n '1f2d1e2e67df' | base64

The output is similar to:

MWYyZDFlMmU2N2Rm
```

Write a Secret that looks like this:

```yml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```


Now create the Secret using kubectl apply:
```
kubectl apply -f ./secret.yaml

The output is similar to:

secret "mysecret" created
```

For example, if your application uses the following configuration file:
```yml
apiUrl: "https://my.api.com/api/v1"
username: "user"
password: "password"
```

You could store this in a Secret using the following definition:

```yml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
stringData:
  config.yaml: |-
    apiUrl: "https://my.api.com/api/v1"
    username: {{username}}
    password: {{password}}
```

Your deployment tool could then replace the {{username}} and {{password}} template variables before running kubectl apply.

The stringData field is a write-only convenience field. It is never output when retrieving Secrets. For example, if you run the following command:

```

kubectl get secret mysecret -o yaml
```
The output is similar to:

```yml
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: 2018-11-15T20:40:59Z
  name: mysecret
  namespace: default
  resourceVersion: "7225"
  uid: c280ad2e-e916-11e8-98f2-025000000001
type: Opaque
data:
  config.yaml: YXBpVXJsOiAiaHR0cHM6Ly9teS5hcGkuY29tL2FwaS92MSIKdXNlcm5hbWU6IHt7dXNlcm5hbWV9fQpwYXNzd29yZDoge3twYXNzd29yZH19

```
If a field, such as username, is specified in both data and stringData, the value from stringData is used. For example, the following Secret definition:
```yml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
stringData:
  username: administrator
```
Results in the following Secret:

```yml
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: 2018-11-15T20:46:46Z
  name: mysecret
  namespace: default
  resourceVersion: "7579"
  uid: 91460ecb-e917-11e8-98f2-025000000001
type: Opaque
data:
  username: YWRtaW5pc3RyYXRvcg==
```
Where YWRtaW5pc3RyYXRvcg== decodes to administrator.

The keys of data and stringData must consist of alphanumeric characters, ‘-', ‘_’ or ‘.'.


[Generating from files](https://kubernetes.io/docs/concepts/configuration/secret/#generating-a-secret-from-files)

[Generating a Secret from string literals](https://kubernetes.io/docs/concepts/configuration/secret/#generating-a-secret-from-string-literals)

#### Using Secrets


örnek 1

```yml
This is an example of a Pod that mounts a Secret in a volume:

apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
```
Consuming Secret values from env

```yml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
  restartPolicy: Never
  ```
