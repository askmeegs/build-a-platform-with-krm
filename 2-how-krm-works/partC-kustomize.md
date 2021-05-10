
## Part C - Deploying CymbalBank with `kustomize`  

Now that we've learned how Kubernetes clusters work, and how to use KRM to deploy workloads to a cluster, let's dive into the CymbalBank application, which we'll use for the rest of the demos. 

The CymbalBank app ([open-sourced here](https://github.com/GoogleCloudPlatform/bank-of-anthos)) is a multi-service retail banking web app, written in Python and Java, that allows users to create accounts, send money to their contacts, and make deposits. The app uses two PostgreSQL databases, for accounts and transactions, both running in Google Cloud SQL. (Two dev databases were provisioned during bootstrapping, but don't have any data yet!)

![cymbal arch](screenshots/cymbal-arch.jpg)

Each CymbalBank service represents one Kubernetes workload. Let's explore the pre-provided Kubernetes manifests for the app. 

#### 1. **Copy the Kubernetes manifests** for CymbalBank into the cymbalbank-app-config repo. 

```
cp -r app-manifests/* cymbalbank-app-config/
```

#### 2. **Explore the cymbalbank-app-config repo.** 

Unlike the nginx example where we used `kubectl` to directly apply a Deployment to a cluster, we'll instead use a tool called [kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/). kustomize allows you to "customize" KRM without custom templating language. Kustomize is now built directly into kubectl, meaning you can run kustomize commands with `kubectl apply -k`. 

View the structure of the config repo using `tree`: 

```
tree cymbalbank-app-config/
```

Expected output: 

```
cymbalbank-app-config/
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

4 directories, 27 files
```

Here, we can see that there's a `base` directory, with YAML files for each CymbalBank service, plus two `overlay` directories, `dev` and `prod`, each with their own YAML file per CymbalBank service. What's going on here? 

#### 3. **Explore the CymbalBank kustomize overlays.** 

kustomize allows for pre-baked "flavors" of a set of Kubernetes manifests, called [overlays](https://kubectl.docs.kubernetes.io/guides/config_management/components/), which helps reduce manual editing of YAML files, while allowing multiple flavors to use the same source YAML. The README in the `cymbalbank-app-config` root directory details the differences between the demo, prod, and dev overlays (different # of deployment replicas, and different `env` variable values.) 

Both overlays rely on the same base manifests for each CymbalBank service. For instance, view the `userservice` base manifests: 

```
cat cymbalbank-app-config/base/contacts.yaml
```

Notice that this file contains multiple Kubernetes resources, separated with the `---` delimiter, including a Deployment, Service, Secret, and ConfigMaps. All of these are standard Kubernetes resources needed for the contacts service to run: 

- **Deployment** - we've seen this one before. Spawns Pods, which run Containers. In this case, the contacts deployment will run the pre-built contacts service container. This container hosts a backend server for various API endpoints related to a CymbalBank customer's contacts, allowing them to send money. Notice that the contacts Deployment also defines a second container, `cloudsql-proxy`, which allows the contacts container to seamlessly connect to Google Cloud SQL in order to access the accounts database. Often when a second "helper" container runs alongside the main container, this is called a "sidecar container." 
- **Service** - a core networking resource in Kubernetes. Allows the contacts deployment to be routable inside and/or outside the cluster. In this case, the Service's type, `ClusterIP`, means that the `contacts` Deployment will only be routable inside the cluster, with the domain name `contacts.default.svc.cluster.local`. 
- **Secret** - provides a JWT public key for authentication. 
- **ConfigMaps**- contain configuration only (`data`) that can be mounted into a Deployment. In this case, we define config for where the accounts database lives- in this case, localhost or `127.0.0.1`, since we're actually talking to the cloud SQL sidecar container in the same Pod. [Containers in the same pod share](https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview#pods) a Linux networking namespace, therefore we list the Cloud SQL proxy endpoint as `127.0.0.1`. 

This baseline config for `contacts` is then extended in the overlays using "patches." A patch is another Kubernetes resource with only the fields specified that you want to override, over the base. View the patch for the dev overlay: 

```
cat cymbalbank-app-config/overlays/dev/contacts.yaml 
```

Expected output: 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: contacts
  namespace: contacts
spec:
  selector:
    matchLabels:
      app: contacts
  template: 
    spec: 
      containers:
      - name: contacts
        env:
        - name: ENABLE_TRACING
          value: "false"
        - name: ENABLE_METRICS
          value: "false"
        - name: LOG_LEVEL
          value: "debug"
```

When kustomize is invoked to apply the full set of resources to the cluster, kustomize will combine the base contacts Deployment with the overlay patch above, resulting in one fully "hydrated" Deployment it will then apply to the cluster. 

#### 4. **Explore kustomization.yaml**. 

The last thing to know about kustomize, for the purpose of this demo, is that each kustomize directory needs a [`kustomization.yaml` file](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#kustomization). This provides the config for kustomize itself, telling it where your config lives and how to merge together your base and overlays. 

View the kustomization.yaml file for the dev overlay: 

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

Here, we define where our base config lives, the set of patches we want to apply over the base, and any "common labels" we want to apply to all the resources we're patching.  

Now, instead of manually deploying the resources to a cluster like we did for `nginx-deployment`, let's set up a Continuous Deployment pipeline to deploy the resources automatically, from GitHub.  

**[Continue to part D - continuous deployment](partD-cd.md)**.