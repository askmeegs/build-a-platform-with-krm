# 2 - How KRM Works 

This demo shows a basic deployment of a Kubernetes application, formatted as KRM, and deployed via Google Cloud Build.

By the end of this demo, you'll have the following setup: 

![demo arch](screenshots/basic-deploy.png)

### Prerequisites 

- Complete [part 1](/1-setup) to bootstrap your environment. 


### Steps 

1. Set vars. 

```
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```


2. **Clone the app config repo.** This Github repo should have been created in your account during setup. 

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
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

1. **Explore the CymbalBank app.** 

![cymbal arch](screenshots/cymbal-arch.png)

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

1. **Copy the app manifests.** Note that for now, we're using release manifests with images that have already been pushed to Google Container Registry. (The next demo will walk through making code changes and deploying new images to staging, then production.) 

```
cp -r app-manifests/* cymbalbank-app-config/
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