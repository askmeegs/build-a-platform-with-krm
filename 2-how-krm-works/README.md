# 2 - How KRM Works 

Now that you have a Kubernetes environment to work with, let's deploy the CymbalBank application, formatted as KRM, to one of the clusters. 


## What you'll learn  

- What KRM stands for 
- How to define a Kubernetes object using KRM 
- How to manually apply a Kubernetes object to a cluster using `kubectl` 
- How to streamline KRM editing using `kustomize` 
- How the CymbalBank application can be expressed as Kubernetes resources 
- How to push KRM resources to a Git repo 
- How to create a Continous Deployment pipeline triggered on a Git repo, to deploy KRM into production. 

## Architecture

![demo arch](screenshots/basic-deploy.png)

## Prerequisites 

1. **Complete [part 1](/1-setup)** to bootstrap your environment. 


## Part A - Setup  

1. `cd` into this directory. 

```
cd 2-how-krm-works/
```

2. **Set variables.**

```
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```


3. **Clone the app config repo.** This Github repo should have been created in your account during setup. This repo will contain the Kubernetes manifests (KRM) for the CymbalBank application. 

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
```

Expected output: 

```
Cloning into 'cymbalbank-app-config'...
warning: You appear to have cloned an empty repository.
```

## Part B - Introducing KRM 

Your cymbalbank-app-config/ repo now contains multiple Kubernetes manifests. Kubernetes manifests are readable by the Kubernetes API and have a specific, structured format. This format is called the [Kubernetes Resource Model](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/resource-management.md), or KRM. KRM can be expressed as either YAML or JSON- here, we're using the YAML format. 

KRM was created with the Kubernetes architecture in mind - because Kubernetes is a declarative system, each KRM resource represents a declarative object with your desired state. Said another way, a KRM resource is a "noun" - for instance, a Deployment - that the Kubernetes control plane will take action on ("verbs") so that your desired state in that YAML file matches the live state in your cluster. (This model will be familiar if you're ever worked with a REST API, or CRUD operations.) For instance, if you have a Deployment YAML stating that you want 3 replicas of a `nginx` Docker image, and one of the replicas fails, Kubernetes will notice that, and will bring another replica back online. Let's try that in action. 

1. `nginx-deployment.yaml` contains a Deployment manifest ([source](https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/)). **Open the file** in an IDE. 

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

2. **Change your local kubecontext** to the `cymbal-dev` cluster. 

```
kubectx cymbal-dev
```

3. **Use `kubectl` to "apply" `nginx-deployment.yaml` to your cluster**. The `kubectl` tool is a command-line interface between a user and a running Kubernetes API server. (All 4 of your GKE clusters have their own API servers.) The `apply` command is like a a REST `put` command - it will create the resource if it doesn't exist, or update it, if the resource already exists. 

```
kubectl apply -f nginx-deployment.yaml
```

Expected output: 

```
deployment.apps/nginx-deployment created
```

4. **View the running Pods** in the cymbal-dev cluster. Pods are the smallest deployable unit of Kubernetes. Each Pod contains one or more running containers - in this case, each of the 3 nginx pods contain 1 nginx container. 

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

5. **Try deleting one of the pods** in your nginx deployment, then re-run `kubectl get pods`. You should see that Kubernetes noticed that the actual state diverged from your desired state in `nginx-deployment.yaml`, and brought a new nginx Pod back online. 

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

![gke architecture](screenshots/gke-arch.png)

All Kubernetes components, and all outside actors - including you, executing `kubectl` commands - interact with the **APIServer**. The API Server, with its storage backend, **etcd**, is the single source of truth for a cluster. This is where both the intended and actual state of each KRM resource lives. 

The **Resource controllers** inside the GKE control plane are basically a set of loops that periodically check "what needs to be done." For instance, if the [Deployment controller]() sees that you just applied a new Deployment to the cluster, it will update that resource as "to be scheduled - 3 pods". Then the **Scheduler**, also periodically checking the API Server, will schedule those 3 pods to the available **Nodes** in your cluster. Each Node runs a process called **kubelet**. The job of the kubelet is to start and stop containers, effectively doing the "last mile" of action to get the cluster's state match your desired state. The kubelet periodically queries the APIServer to see if it has any jobs to do - for instance, start or stop a container using its container runtime (eg. Docker, or in the case of GKE, [containerd](https://cloud.google.com/kubernetes-engine/docs/concepts/using-containerd))

So when you ran `kubectl apply -f`, a series of events happened ([in-depth steps here](https://github.com/jamiehannaford/what-happens-when-k8s)): 
1. `kubectl` validated your Deployment file
2. `kubectl` authenticated to the `cymbal-dev` Kubernetes APIServer.
3. The Kubernetes APIServer "admitted" the resource into the API 
4. The Kubernetes APIServer stored the resource in `etcd`. 
5. The Kubernetes Controllers responsible for Deployments picked up on the new Deployment in their next loop, and marked 3 replicas as "Pending" / to be scheduled 
6. The Kubernetes Scheduler sees the `Pending` Pods and finds suitable Nodes for the Pods to run on. (eg. checks if the Node has enough CPU/Memory to run that Pod)
7. kubelet on assigned node starts an nginx container (x3)

Now that we know that every Kubernetes actor, including you, ultimately interacts with the same object in etcd, let's look at our deployment after Kubernetes has taken action on it. 

8. **Get your deployment out of the APIServer using `kubectl`**. 

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

## Part C - Deploying CymbalBank with `kustomize`  

Now that we've learned how Kubernetes clusters work, and how to use KRM to deploy workloads to a cluster, let's dive into the CymbalBank application, which we'll use for the rest of the demos. 

The CymbalBank app is a multi-service retail banking web app, written in Python and Java, that allows users to create accounts, send money to their contacts, and make deposits. The app uses two PostgreSQL databases, for accounts and transactions, both running in Google Cloud SQL. (Two dev databases were provisioned during bootstrapping, but don't have any data yet!)

![cymbal arch](screenshots/cymbal-arch.png)


~~~~~

4. **Copy the Kubernetes manifests** for CymbalBank into the cymbalbank-app-config repo. 

```
cp -r app-manifests/* cymbalbank-app-config/
```


1. **View the Continous Deployment pipeline.** This pipeline will run in Google Cloud Build, and it deploys the CymbalBank application manifests, formatted as KRM, to the production cluster created during setup. The `-k` flag passed to kubectl apply means that kubectl is invoking the kustomize tool to "hydrate" KRM manifests for production - we'll learn more about this in the next demo. For now, the key points are that this Cloud Build pipeline is taking KRM and applying it to a Kubernetes cluster in order to deploy the CymbalBank app. 

```
cat cloudbuild-cd-prod.yaml
```

Expected output: 

```
steps:
- name: 'gcr.io/cloud-builders/kubectl'
  id: Deploy
  args:
  - 'apply'
  - '-k'
  - 'overlays/prod/'
  env:
  - 'CLOUDSDK_COMPUTE_ZONE=us-west1-a'
  - 'CLOUDSDK_CONTAINER_CLUSTER=cymbal-prod'
```

1. **Copy the cloud build Continuous Deployment (CD) pipeline into the repo.**

```
cp cloudbuild-cd-prod.yaml cymbalbank-app-config/
```


1. **View the CymbalBank app manifests.** 

```
cat app-manifests/base/userservice.yaml
```

Expected output: 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: userservice
  namespace: userservice
spec:
  selector:
    matchLabels:
      app: userservice
  template:
    metadata:
      labels:
        app: userservice
    spec:
      serviceAccountName: cymbal-ksa
      terminationGracePeriodSeconds: 5
      containers:
      - name: userservice
        image: gcr.io/bank-of-anthos/userservice:v0.4.3
```

1. **Push to the app config repo `main` branch**. This will trigger the CD pipeline in Cloud Build. 

```
cd cymbalbank-app-config/
git add .
git commit -m "Initialize app config repo, trigger prod deploy"
git push origin main
cd .. 
```

1. **Open the Google Cloud Console, and navigate to Cloud Build.** Watch the CD pipeline complete. 


1. Get pods in your prod cluster. 

```
kubectx cymbal-prod; kubectl get pods --all-namespaces --selector=org=cymbal-bank
```

Expected output: 

```
NAMESPACE            NAME                                  READY   STATUS    RESTARTS   AGE
balancereader        balancereader-f68c878c5-fgz4q         2/2     Running   0          32m
contacts             contacts-7b858c69dd-n5wp2             2/2     Running   0          32m
frontend             frontend-6997bd6bb9-h5vcm             1/1     Running   0          32m
ledgerwriter         ledgerwriter-55bd67f97-7zmxs          2/2     Running   0          32m
loadgenerator        loadgenerator-c449f87cb-gnbq2         1/1     Running   0          32m
transactionhistory   transactionhistory-55f4cd4767-8655g   2/2     Running   0          32m
userservice          userservice-5cc7849549-tf5gr          2/2     Running   0          32m
```


## Further Reading

https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/

https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/resource-management.md

https://github.com/jamiehannaford/what-happens-when-k8s 

https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture#control_plane 

https://kubernetes.io/docs/concepts/architecture/controller/ 