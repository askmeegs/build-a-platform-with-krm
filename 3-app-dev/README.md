# 3 - App Development with KRM   

This demo shows how an app developer can develop features in a Kubernetes environment using GKE, skaffold, and kustomize, without having to directly work with any YAML (KRM) files. 

### Prerequisites 

Complete demo [parts 1](/1-setup) and [2](/2-how-krm-works). 

### Part A - Setup  

1. **Set variables.**

```
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```

2. **Clone and initialize the app source repo** by copying the upstream [Bank of Anthos](https://github.com/googlecloudplatform/bank-of-anthos) sample app source code into your app-source-repo. Then remove the upstream Bank of Anthos repo from your local environment.  

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-source"
git clone "https://github.com/GoogleCloudPlatform/bank-of-anthos"
cp -r bank-of-anthos/ cymbalbank-app-source/ 
rm -rf bank-of-anthos 
```

3. **Clone the app config repo** inside the app source repo, as a Git submodule. The reason for doing this is so that `skaffold`, the tool that builds the Docker images, has the YAML files it needs to deploy to the dev GKE cluster. 

```
cd cymbalbank-app-source 
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
cd ..
```

4. **View the Cloud Build pipeline for Pull Requests to the app source repo**. 

```
cat cloudbuild-ci-pr.yaml
```

This pipeline will run when the app developer puts out a Pull Request in the app source repo. The pipeline builds and deploys the source code in the app developer's PR branch to the staging cluster. Note that in a real environment, we would add unit and integration tests to this pipeline as well. We can also run smoke tests (eg. ping tests, functional tests, load tests) on the staged GKE deployment, which mimics a prod environment. 

```
steps:
- name: 'gcr.io/k8s-skaffold/skaffold:latest'
  id: Deploy to Staging Cluster
  args:
  - 'run'
  - '--default-repo'
  - 'gcr.io/${PROJECT_ID}/cymbal-bank/${BRANCH_NAME}'
  env:
  - 'CLOUDSDK_COMPUTE_ZONE=us-central1-a'
  - 'CLOUDSDK_CONTAINER_CLUSTER=cymbal-staging'
```

5. **View the Cloud Build pipeline for commits to the `main` branch of the app source repo** 

```
cat cloudbuild-ci.main.yaml 
```

This pipeline runs when a pull request merges into the `main` branch. It does 4 things: 
1. Builds production images based on the source code that has just landed to the `main branch`. Those images are pushed to Google Container Registry in your project.
2. Clones the `cymbalbank-app-config` repo. 
3. Injects the new image tags into the deployment manifests in `cymbalbank-app-config`. 
4. Pushes those changes to the `main` branch of `cymbalbank-app-config`.  

Note that `cymbalbank-app-config` commits to the `main` branch trigger the Continuous Deployment pipeline we used in [Part 2](/2-how-krm-works). While we ran the Cloud Build trigger manually that time - using upstream release images rather than CI-generated images - this workflow will trigger it automatically. We'll see this in a few steps. 

5. **Copy the Cloud Build pipelines into the source repo.** 

```
cp cloudbuild-ci-pr.yaml cymbalbank-app-source/
cp cloudbuild-ci-main.yaml cymbalbank-app-source/
```

7. **Push the Cloud Build pipelines to the main branch** of your app source repo. 

```
cd cymbalbank-app-source/ 
git add .
git commit -m "Add cloudbuild.yaml"
git push origin main 
```

### Part B - Build + Test a Feature

In this section, we'll make an update to the CymbalBank frontend source code, test it using a local Kubernetes toolchain, then put out a Pull Request to trigger the CI/CD workflow described above. 

![partB](screenshots/dev-test.png)

1. **Check out a new local branch** in the cymbalbank-app-source repo. 

```
git checkout -b frontend-banner 
```

2. **Update the frontend source code** by adding a banner to the login page advertising a new interest rate on all checking accounts. In an IDE, open `cymbalbank-app-source/src/frontend/templates/login.html`. Under line , add the following code: 

```

```

3. **Get ready to test your code changes** in the dev GKE cluster. We'll use a tool called [skaffold](https://skaffold.dev) to build Docker images and deploy to the dev GKE cluster. Install skaffold to your local environment by [following the steps here](https://skaffold.dev/docs/install/). 

4. **View the `skaffold.yaml` file**. 


```
cat ../skaffold.yaml 
```

Expected output: 

```
apiVersion: skaffold/v2alpha4
kind: Config
build:
  artifacts:
  - image: frontend
    context: src/frontend
  - image: ledgerwriter
    jib:
      project: src/ledgerwriter
  - image: balancereader
    jib:
      project: src/balancereader
  - image: transactionhistory
    jib:
      project: src/transactionhistory
  - image: contacts
    context: src/contacts
  - image: userservice
    context: src/userservice
  - image: loadgenerator
    context: src/loadgenerator
  tagPolicy:
    gitCommit: {}
  local:
    concurrency: 0
deploy:
  statusCheckDeadlineSeconds: 300
  kustomize: {}
profiles:
  - name: dev
    deploy: 
      kustomize: 
        paths:
          - "cymbalbank-app-config/overlays/dev"
  - name: staging 
  - name: prod 
```

Some info on how this file works: 
- A skaffold.yaml file defines configuration that the skaffold tool will use to build container images. 
- Here, we're telling skaffold to build multiple container images (`artifacts`) - frontend, ledgerwriter, etc.. 
- The Java images will be built with [Jib](https://github.com/GoogleContainerTools/jib/), a container building tool for Java, and the Python images (frontend, userservice, contacts, loadgenerator) will be built with the default Docker. 
- We're using the 
- We define multiple [profiles](), including dev, staging, and prod, which 


- Skaffold uses KRM to define its own API - meaning, you're using KRM (this config file) to deploy KRM (the manifests in `cymbalbank-app-config`). More specifically, skaffold defines its own Kubernetes API (`skaffold`), versioned at `v2alpha4`, with a `kind` and various subfields. 


5. **Copy `skaffold.yaml`** into your app source repo. 

```
cp ../skaffold.yaml .
```

6. **Explore the cymbalbank-app-config**  manifests. Once skaffold builds the container images for the various CymbalBank services, it will use these Kubernetes resources to deploy to the dev cluster. 

One way to deploy KRM to a cluster is simply putting YAML files in a directory and running `kubectl apply -f my-directory/`. Here instead, we're using kustomize to define a `base` set of application KRM and two `overlays`, `dev` and `prod`. In kustomize, the base config is shared config - in this case, most of the Deployment and Service files we need. Overlays are specific "flavors" of configuration representing different environments or use cases, such as ["enterprise" vs. "community" edition](https://kubectl.docs.kubernetes.io/guides/config_management/components/) of an app. 


```
tree cymbalbank-app-config/ 
```

Expected output: 

```
cymbalbank-app-config
├── README.md
├── base
│   ├── balancereader.yaml
│   ├── contacts.yaml
│   ├── frontend.yaml
│   ├── kustomization.yaml
│   ├── ledgerwriter.yaml
│   ├── loadgenerator.yaml
│   ├── populate-accounts-db.yaml
│   ├── populate-ledger-db.yaml
│   ├── transactionhistory.yaml
│   └── userservice.yaml
├── cloudbuild-cd-prod.yaml
└── overlays
    ├── dev
    │   ├── balancereader.yaml
    │   ├── contacts.yaml
    │   ├── frontend.yaml
    │   ├── kustomization.yaml
    │   ├── ledgerwriter.yaml
    │   ├── loadgenerator.yaml
    │   ├── transactionhistory.yaml
    │   └── userservice.yaml
    └── prod
        ├── balancereader.yaml
        ├── contacts.yaml
        ├── frontend.yaml
        ├── kustomization.yaml
        ├── ledgerwriter.yaml
        ├── loadgenerator.yaml
        ├── transactionhistory.yaml
        └── userservice.yaml

4 directories, 28 files
```

7. **View a `kustomization.yaml` file**. Each kustomize directory must have a [`kustomization.yaml` file](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/). This is another piece of KRM configuration that lists what files should be deployed: 

```
cat cymbal-app-config/base/kustomization.yaml
```

Expected output: 

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- balancereader.yaml
- contacts.yaml
- ledgerwriter.yaml
- loadgenerator.yaml
- populate-accounts-db.yaml
- populate-ledger-db.yaml
- transactionhistory.yaml
- userservice.yaml
- frontend.yaml
```

7. **Explore the kustomize overlays.** 

The `dev` and `prod` overlays add custom configuration for the following CymbalBank fields: 

|      | 🔎 **Tracing** | 📊 **Metrics** | 📝 **Log Level** | 🏦 **Frontend Replicas** |
|------|---------|---------|-----------|---------------------|
| 💻 **Dev**  | off     | off     | `debug`   | 1                   |
| 🚀 **Prod** | on      | on      | `info`    | 3                   |

In this case, the `ENABLE_TRACING`, `ENABLE_METRICS`, and `LOG_LEVEL` fields are environment variables in each service Deployment YAML. The frontend replicas field - or the number of frontend Pods we want deployed - is defined in the frontend Deployment spec. 

You'll see from the output of the `tree` command above that  the `dev` and `prod` overlays each define their own flavor of each service. But in kustomize, you only need to override the fields you care about, meaning the `dev` overlay `frontend.yaml` is not a full Kubernetes Resource; it only overrides the fields in the table above: 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend 
spec:
  selector:
    matchLabels:
      app: frontend
  replicas: 1
  template: 
    spec: 
      containers:
      - name: front
        env:
        - name: ENABLE_TRACING
          value: "false"
        - name: LOG_LEVEL
          value: "debug"
```

The rest of the frontend Deployment fields are defined in the `base/frontend.yaml` file. 


8. **Explore an overlay's `kustomization.yaml` file.** 

Each overlay also has a `kustomization.yaml` file that defines where the base config lives, the "patches," or config overrides, to apply, as well as any overlay-specific labels. In this case we'll apply `environment: dev` to all the KRM resources deployed with the dev overlay. 

```
cat cymbal-app-config/overlays/dev/kustomization.yaml
```

Expected output: 

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ../../base
patchesStrategicMerge:
- balancereader.yaml
- contacts.yaml
- ledgerwriter.yaml
- loadgenerator.yaml
- transactionhistory.yaml
- userservice.yaml
- frontend.yaml
commonLabels:
  environment: dev
```

9. **Use skaffold to build images + deploy the using the `dev` overlay.** 

While you can manually deploy a kustomize overlay like this: `kubectl apply -k overlays/dev` (much like the standard `kubectl apply -f`), we'll use skaffold to automatically deploy the `overlays/dev` overlay.  

Run `skaffold dev` to build and deploy your code changes to the dev cluster, using the `dev` profile. Note that `skaffold dev` builds and pushes images, deploys the Kubernetes resources to the cluster, then waits -- if you make any other code changes, skaffold will pick that up and rebuild + redeploy the images. 

```
kubectx cymbal-dev
skaffold dev --profile=dev --default-repo=gcr.io/${PROJECT_ID}/cymbal-bank --tail=false 
```

Expected output: 

```
Deployments stabilized in 1 minute 5.44 seconds
Press Ctrl+C to exit
Watching for changes...
```

10.  View your newly-built pods. 

```
kubectl get pods --all-namespaces --selector=org=cymbal-bank
```

Expected output: 

```
NAMESPACE            NAME                                  READY   STATUS    RESTARTS   AGE
balancereader        balancereader-55dc9b5878-jjbfp        2/2     Running   0          112s
contacts             contacts-66b888c46c-ntkms             2/2     Running   0          112s
frontend             frontend-5687494d77-rh58h             1/1     Running   0          112s
ledgerwriter         ledgerwriter-5876d47fd6-g6hm8         2/2     Running   0          111s
loadgenerator        loadgenerator-ffd746b7f-q59z9         1/1     Running   0          111s
transactionhistory   transactionhistory-68c4b9ccd6-nwh24   2/2     Running   0          111s
userservice          userservice-558fcc7fc4-fndgm          2/2     Running   0          111s
```

11. View the new frontend banner by copying the `EXTERNAL_IP` of your frontned services, pasting it on a browser, and navigating to the frontend UI. 

```
kubectl get svc -n frontend frontend 
```

You should see your new banner at the top of the login screen: 

![screenshot](screenshots/login-banner.png)

### Part C - Pull Request --> Staging

![screeenshot](screenshots/pull-request-ci.png)
 
1. Push the code to the new branch, and put out a pull request in the app source repo. 

```
cd cymbalbank-app-source/ 
git checkout main
git add .
git commit -m "Initialize app source repo"
git push origin main 
cd ..
```

1. Watch Cloud Build - CI - PR. 


1. Switch to the staging cluster and view the frontend banner in staging. 

1. Merge the PR. Watch Cloud Build - CI - Main. 

### Part D - Main CI 

![screenshot](screenshots/main-ci.png)

1. Merge the PR. Watch Cloud Build - CI - Main. 


#### Part E - CD 

![screenshot](screenshots/prod-cd.png)

1. Watch Cloud Build - CD - Prod. 


1. View the new frontend banner running in production. 




### Learn More 

https://kustomize.io/

https://github.com/kubernetes-sigs/kustomize/tree/master/examples

https://github.com/kubernetes-sigs/kustomize

https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

https://kubectl.docs.kubernetes.io/guides/config_management/components/