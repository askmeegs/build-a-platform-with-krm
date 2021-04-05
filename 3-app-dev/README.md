# 3 - App Development with KRM   

This demo shows how an app developer can develop features in a Kubernetes environment using GKE, skaffold, and kustomize, without having to directly work with any YAML (KRM) files. 

**Tools and products covered in this demo:**
- GKE 
- kustomize 
- Cloud Code / skaffold 
- Cloud Build 

## Prerequisites 

Complete demo [parts 1](/1-setup) and [2](/2-how-krm-works). 

## Part A - Setup  

1. [Install VSCode](https://code.visualstudio.com/Download) on your local machine. This is the IDE you'll use to build and test a feature.

2. Open VSCode and install the [Google Cloud Code extension](https://cloud.google.com/code/docs/vscode/install) by clicking on the Extensions icon in the left sidebar (4 blocks) and searching for "cloud code." Click "install."

3. Open a Terminal and **set variables.**

```
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```

4. Switch to the `cymbal-dev` kubecontext. 

```
kubectx cymbal-dev
```


5. **Clone and initialize the app source repo** by copying the upstream [Bank of Anthos](https://github.com/googlecloudplatform/bank-of-anthos) sample app source code into your app-source-repo. Then remove the upstream Bank of Anthos repo from your local environment.  

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-source"
git clone "https://github.com/GoogleCloudPlatform/bank-of-anthos"
cp -r bank-of-anthos/ cymbalbank-app-source/ 
rm -rf bank-of-anthos 
```

6. **Clone the app config repo** inside the app source repo, as a Git submodule. The reason for doing this is so that `skaffold`, the tool that builds the Docker images, has the YAML files it needs to deploy to the dev GKE cluster. 

```
cd cymbalbank-app-source 
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
cd ..
```
<!-- 
7. **Copy the Cloud Build pipelines into the source repo.** We will watch these pipelines run later in this demo. 

```
cp cloudbuild-ci-pr.yaml cymbalbank-app-source/
cp cloudbuild-ci-main.yaml cymbalbank-app-source/
``` -->

<!-- 8. **Push the Cloud Build pipelines to the main branch** of your app source repo. 

```
cd cymbalbank-app-source/ 
git init
git add .
git commit -m "Add cloudbuild.yaml"
git branch -M main
git remote add origin "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-source.git" 
git push -u origin main
``` -->

## Part B - Add an Application Feature 

In this section, we'll make an update to the CymbalBank frontend source code, test it using a local Kubernetes toolchain, then put out a Pull Request to trigger the CI/CD workflow described above. 

![partB](screenshots/dev-test.png)

1. **Check out a new local branch** in the cymbalbank-app-source repo. 

```
git checkout -b frontend-banner 
```

2. **Update the frontend source code** by adding a banner to the login page advertising a new interest rate on all checking accounts. Return to VSCode and open `cymbalbank-app-source/src/frontend/templates/login.html`. Under line 71, add the following code: 

```
          <div class="col-lg-6 offset-lg-3">
            <div class="card">
              <div class="card-body">
                <h5><strong>New!</strong> 0.20% APY on all new checking accounts. <a href="/signup">Sign up today.</a></h5>
              </div>
            </div>
          </div>
```

## Part C - Test the feature 

1. **Get ready to test your code changes** in the dev GKE cluster. We'll use Cloud Code, backed by a tool called [skaffold](https://skaffold.dev) to build Docker images and deploy to the dev GKE cluster. Install skaffold to your local environment by [following the steps here](https://skaffold.dev/docs/install/). 

2. **View the `skaffold.yaml` file**. 


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
    concurrency: 4 
  googleCloudBuild:
    concurrency: 4 
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
    deploy: 
      kustomize: 
        paths:
          - "cymbalbank-app-config/overlays/prod"
  - name: prod
    deploy: 
      kustomize: 
        paths:
          - "cymbalbank-app-config/overlays/prod"

```

More info: 
- A skaffold.yaml file defines configuration that the skaffold tool will use to build container images. 
- Skaffold uses KRM to define its own API - meaning, you're using KRM (this config file) to deploy KRM (the manifests in `cymbalbank-app-config`). More specifically, skaffold defines its own Kubernetes API (`skaffold`), versioned at `v2alpha4`, with a `kind` and various subfields. 
- Here, we're telling skaffold to build multiple container images (`artifacts`) - frontend, ledgerwriter, etc.. 
- The Java images will be built with [Jib](https://github.com/GoogleContainerTools/jib/), a container building tool for Java, and the Python images (frontend, userservice, contacts, loadgenerator) will be built with the default Docker. 
- We define multiple [profiles](https://skaffold.dev/docs/environment/profiles/), including dev, staging, and prod. Each uses a different "flavor," or overlay, of the Kubernetes manifests stored in cymbalbank-app-config (Described in more detail in the `kustomize` section below.)


3. **Copy `skaffold.yaml`** into your app source repo. 

```
cp ../skaffold.yaml .
```

4. **Explore the cymbalbank-app-config**  manifests. Once skaffold builds the container images for the various CymbalBank services, it will use these Kubernetes resources to deploy to the dev cluster. 

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

5. **View a `kustomization.yaml` file**. Each kustomize directory must have a [`kustomization.yaml` file](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/). This is another piece of KRM configuration that lists what files should be deployed: 

```
cat cymbalbank-app-config/base/kustomization.yaml
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

6. **Explore the kustomize overlays.** 

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


7. **Explore an overlay's `kustomization.yaml` file.** 

Each overlay also has a `kustomization.yaml` file that defines where the base config lives, the "patches," or config overrides, to apply, as well as any overlay-specific labels. In this case we'll apply `environment: dev` to all the KRM resources deployed with the dev overlay. 

```
cat cymbalbank-app-config/overlays/dev/kustomization.yaml
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

8. **Use Cloud Code and skaffold to build images + deploy the using the `dev` overlay.** 

It's possible to manually deploy a kustomize overlay (with `kubectl apply -k my-app/` much like you'd manually deploy regular Kubernetes manifests with `kubectl apply -f`. Here instead, [we'll use Cloud Code](https://cloud.google.com/code/docs/vscode/running-an-application), backed by skaffold and kustomize, to deploy the `dev`  profile to the `cymbal-dev` cluster. To do this:  

- Set the Google Container Registry repo where your test images will live
- Press `shift-command-p` inside VSCode. 
- In the command prompt that appears, type `Cloud Code: Debug on Kubernetes`. A drop-down option should appear; click it. 
- In the skaffold.yaml prompt that appears, choose `cymbalbank-app-source/skaffold.yaml` 
- In the "profiles" prompt that appears, choose `dev`. 
- In the kubecontext prompt that appears, choose `cymbal-dev` 
- In the "image registry" prompt that appears, set to: `gcr.io/project-id/cymbal-bank/test`, replacing `project-id` with your project ID. 

A terminal should open up within VSCode that shows the skaffold logs, as it builds images and deploys to the dev cluster. 

<!-- **Note** that you can manually run the skaffold command line tool to accomplish the same thing: 

```
skaffold dev --profile=dev --default-repo=gcr.io/${PROJECT_ID}/cymbal-bank --tail=false 
``` -->

Expected Cloud Code output: 

```
Resource userservice:deployment/userservice status completed successfully
Resource contacts:deployment/contacts status completed successfully
Resource frontend:deployment/frontend status completed successfully
...
```

9.  Open a new terminal window and **view your newly-built pods**. 

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

10. View the new frontend banner by copying the `EXTERNAL_IP` of your frontned services, pasting it on a browser, and navigating to the frontend UI. 

```
kubectl get svc -n frontend frontend 
```

You should see your new banner at the top of the login screen: 

![screenshot](screenshots/login-banner.png)


## Part C - Pull Request --> Staging

![screeenshot](screenshots/pull-request-ci.png)
 

1. **View the Cloud Build pipeline for Pull Requests to the app source repo**. 

```
cat cloudbuild-ci-pr.yaml
```

This pipeline will run when we put out a Pull Request in the app source repo. The pipeline builds and deploys the source code in the app developer's PR branch to the staging cluster. Note that in a real environment, we would add unit and integration tests to this pipeline as well. We can also run smoke tests (eg. ping tests, functional tests, load tests) on the staged GKE deployment, which mimics a prod environment. 

```
# TODO - break into separate steps? 
steps: 
- name: 'gcr.io/google-samples/intro-to-krm/skaffold-mvn:latest'
  id: Deploy to Staging Cluster 
  entrypoint: /bin/sh
  args:
  - '-c'
  - |
    git clone "https://github.com/$$GITHUB_USERNAME/cymbalbank-app-config"
    gcloud container clusters get-credentials ${_CLUSTER_NAME} --zone ${_CLUSTER_ZONE} --project ${PROJECT_ID} 
    skaffold run --profile=staging --default-repo="gcr.io/${PROJECT_ID}/cymbal-bank/${BRANCH_NAME}" --tail=false
    kubectl wait --for=condition=available --timeout=300s deployment/frontend -n frontend 
    kubectl wait --for=condition=available --timeout=300s deployment/contacts -n contacts 
    kubectl wait --for=condition=available --timeout=300s deployment/userservice -n userservice 
    kubectl wait --for=condition=available --timeout=300s deployment/ledgerwriter -n ledgerwriter 
    kubectl wait --for=condition=available --timeout=300s deployment/transactionhistory -n transactionhistory 
    kubectl wait --for=condition=available --timeout=300s deployment/balancereader -n balancereader 
    kubectl wait --for=condition=available --timeout=300s deployment/loadgenerator -n loadgenerator
  secretEnv: ['GITHUB_USERNAME']
substitutions:
  _CLUSTER_NAME: 'cymbal-staging'
  _CLUSTER_ZONE: 'us-central1-a'
availableSecrets:
  secretManager:
  - versionName: projects/${PROJECT_ID}/secrets/github-username/versions/1 
    env: 'GITHUB_USERNAME'
```


2. Copy the cloud build PR pipeline, then push the source code to a remote branch. 

```
cp ../cloudbuild-ci-pr.yaml . 
cp ../cloudbuild-ci-main.yaml .
git add .
git commit -m "Add frontend banner, PR CI pipeline" 
git push origin frontend-banner
```

3. Navigate to Github > cymbalbank-app-source and open a pull request in your `frontend-banner` branch. This will trigger the `cloudbuild-ci-pr.yaml` Cloud Build pipeline.  

![github-pr](screenshots/github-open-pr.png)

4. Watch Cloud Build - CI - PR complete.  


5. Switch to the staging cluster and view the frontend banner in staging. 


## Part E - Main CI 

![screenshot](screenshots/main-ci.png)


1. **View the Cloud Build pipeline for commits to the `main` branch of the app source repo** 

```
cat cloudbuild-ci.main.yaml 
```

This pipeline runs when a pull request merges into the `main` branch. It does 4 things: 
1. Builds production images based on the source code that has just landed to the `main branch`. Those images are pushed to Google Container Registry in your project.
2. Clones the `cymbalbank-app-config` repo. 
3. Injects the new image tags into the deployment manifests in `cymbalbank-app-config`. 
4. Pushes those changes to the `main` branch of `cymbalbank-app-config`.  

Note that `cymbalbank-app-config` commits to the `main` branch trigger the Continuous Deployment pipeline we used in [Part 2](/2-how-krm-works). While we ran the Cloud Build trigger manually that time - using upstream release images rather than CI-generated images - this workflow will trigger it automatically. We'll see this in a few steps. 

2. Merge the frontend-banner pull request. Watch Cloud Build - CI - Main. 


3. When it completes, navigate to Github and open the cymbalbank-app-config repo. In the `base/` Kubernetes manfiests, you should see a new image tag, committed seconds ago. 

## Part F - Continuous Deployment  

![screenshot](screenshots/prod-cd.png)

The Cloud Build CD pipeline - which deploys the "hydrated" cymbalbank-app-config manifests to the prod cluster - is triggered by commits to cymbalbank-app-config's main branch, like the one that the CI pipeline just did. All this pipeline does is run `kubectl apply -k` on the prod overlay - remember that overlays use the base manifests, so the prod overlay will bring in the new images, and apply the prod-specific config (like a reduced log level, and enabling tracing) before deploy. 

1. Watch Cloud Build - CD - Prod. 


2. View the new frontend banner running in production. 



Note that this CD pipeline is very simple - in reality, you'd likely have a progressive deploy to production - such as a Kubernetes rolling update or a Canary Deployment using a service mesh or similar tool. By slowly rolling out the new containers into the production GKE environment, and monitoring whether requests are successul, you can safeguard against a production outage or performance degradations. 

🎉 Congrats! You just developed a new CymbalBank feature, tested it in a live Kubernetes environment, and deployed it into production. All without editing a single YAML file. 

## Learn More 

https://kustomize.io/

https://github.com/kubernetes-sigs/kustomize/tree/master/examples

https://github.com/kubernetes-sigs/kustomize

https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

https://kubectl.docs.kubernetes.io/guides/config_management/components/

https://cloud.google.com/code/docs/vscode/setting-up-an-existing-app#setting_up_configuration_for_applications_that_already_have_skaffoldyaml 