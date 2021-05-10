
## Part B - Introducing KRM 

Your cymbalbank-app-config/ repo now contains multiple Kubernetes manifests. Kubernetes manifests are readable by the Kubernetes API and have a specific, structured format. This format is called the [Kubernetes Resource Model](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/resource-management.md), or KRM. KRM can be expressed as either YAML or JSON- here, we're using the YAML format. 

KRM was created with the Kubernetes architecture in mind - because Kubernetes is a declarative system, each KRM resource represents a declarative object with your desired state. Said another way, a KRM resource is a "noun" - for instance, a Deployment - that the Kubernetes control plane will take action on ("verbs") so that your desired state in that YAML file matches the live state in your cluster. (This model will be familiar if you're ever worked with a REST API, or CRUD operations.) For instance, if you have a Deployment YAML stating that you want 3 replicas of a `nginx` Docker image, and one of the replicas fails, Kubernetes will notice that, and will bring another replica back online. Let's try that in action. 

#### 1. **View the nginx deployment.** 


`nginx-deployment.yaml` contains a Deployment manifest ([source](https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/)). **Open the file** in an IDE. 

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

All [Kubernetes objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/) have the following fields:
- `apiVersion` - the API + Version for this resource. Kubernetes has multiple APIs, each with their own version. 
- `kind` - the resource type within that API. 
- `metadata` - information about the object - like labels, annotations, name, [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). When you create this resource in a cluster, Kubernetes will add its own metadata, including a unique ID, `UID`, for that specific object. 
- `spec` - the fields specific to that object. In a Deployment spec, for instance, you have to define the container `image` you want to use. Also notice how we'll deploy 3 `replicas` of the same container - this allows for basic scaling.     

#### 2. **Change your local kubecontext** to the `cymbal-dev` cluster. 

```
kubectx cymbal-dev
```

#### 3. Apply `nginx-deployment.yaml` to the cluster**. 

The `kubectl` tool is a command-line interface between a user and a running Kubernetes API server. (All 4 of your GKE clusters have their own API servers.) The `apply` command is like a a REST `put` command - it will create the resource if it doesn't exist, or update it, if the resource already exists. 

```
kubectl apply -f nginx-deployment.yaml
```

Expected output: 

```
deployment.apps/nginx-deployment created
```

#### 4. **View the running Pods** in the cymbal-dev cluster. 

Pods are the smallest deployable unit of Kubernetes. Each Pod contains one or more running containers - in this case, each of the 3 nginx pods contain 1 nginx container. 

```
kubectl get pods 
```

Expected output: 

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6b474476c4-h4j4q   1/1     Running   0          21s
nginx-deployment-6b474476c4-knmkr   1/1     Running   0          21s
nginx-deployment-6b474476c4-q77jr   1/1     Running   0          21s
```

#### 5. **Try deleting one of the pods** in your nginx deployment.

Then re-run `kubectl get pods`. You should see that Kubernetes noticed that the actual state diverged from your desired state in `nginx-deployment.yaml`, and brought a new nginx Pod back online. 

```
kubectl delete pod nginx-deployment-6b474476c4-h4j4q 
kubectl get pods
```

Expected output: 

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6b474476c4-44dq4   1/1     Running   0          2s
nginx-deployment-6b474476c4-knmkr   1/1     Running   0          3m45s
nginx-deployment-6b474476c4-q77jr   1/1     Running   0          3m45s
```

**What actually happened** when we ran `kubectl apply`? `kubectl` abstracts what is actually a complex process of getting KRM from your local machine into a Kubernetes cluster.

For starters, it's helpful to understand what's inside a Kubernetes cluster - in this case, [GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture). 

![gke architecture](screenshots/gke-arch.jpg)

All Kubernetes components, and all outside actors - including you, executing `kubectl` commands - interact with the **APIServer**. The API Server, with its storage backend, **etcd**, is the single source of truth for a cluster. This is where both the intended and actual state of each KRM resource lives. 

The **Resource controllers** inside the GKE control plane are basically a set of loops that periodically check "what needs to be done." For instance, if the Deployment controller sees that you just applied a new Deployment to the cluster, it will update that resource as "to be scheduled - 3 pods". Then the **Scheduler**, also periodically checking the API Server, will schedule those 3 pods to the available **Nodes** in your cluster. Each Node runs a process called **kubelet**. The job of the kubelet is to start and stop containers, effectively doing the "last mile" of action to get the cluster's state match your desired state. The kubelet periodically queries the APIServer to see if it has any jobs to do - for instance, start or stop a container using its container runtime (eg. Docker, or in the case of GKE, [containerd](https://cloud.google.com/kubernetes-engine/docs/concepts/using-containerd))

So when you ran `kubectl apply -f`, a series of events happened ([in-depth steps here](https://github.com/jamiehannaford/what-happens-when-k8s)): 
1. `kubectl` validated your Deployment file
2. `kubectl` authenticated to the `cymbal-dev` Kubernetes APIServer.
3. The Kubernetes APIServer "admitted" the resource into the API 
4. The Kubernetes APIServer stored the resource in `etcd`. 
5. The Kubernetes Controllers responsible for Deployments picked up on the new Deployment in their next loop, and marked 3 replicas as "Pending" / to be scheduled 
6. The Kubernetes Scheduler sees the `Pending` Pods and finds suitable Nodes for the Pods to run on. (eg. checks if the Node has enough CPU/Memory to run that Pod)
7. kubelet on assigned node starts an nginx container (x3)

Now that we know that every Kubernetes actor, including you, ultimately interacts with the same object in etcd, let's look at our deployment after Kubernetes has taken action on it. 

#### 6. **Get your deployment out of the APIServer using `kubectl`**. 

```
kubectl get deployment nginx-deployment -o yaml 
```

Expected output (abbreviated): 

```YAML 
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},"spec":{"replicas":3,"selector":{"matchLabels":{"app":"nginx"}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"containers":[{"image":"nginx:1.14.2","name":"nginx","ports":[{"containerPort":80}]}]}}}}
  creationTimestamp: "2021-04-09T17:20:01Z"
  generation: 1
  managedFields:
...
status:
  availableReplicas: 3
  conditions:
  - lastTransitionTime: "2021-04-09T17:20:03Z"
    lastUpdateTime: "2021-04-09T17:20:13Z"
    message: ReplicaSet "nginx-deployment-6b474476c4" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
 ....
```

You'll notice that this YAML file is much longer than the one you defined in `nginx-deployment.yaml`. This is because the Kubernetes control plane has added some fields - new metadata, for instance, plus a field called `status`. This represents the live state of your Deployment, along with a log of actions Kubernetes took to get your Pods online.  

9. Clean up by deleting the nginx-deployment from the cluster. 

```
kubectl delete -f nginx-deployment.yaml 
```

**[Continue to part C - kustomize](partC-kustomize.md)**. 