
## Part B - Administering KRM with Config Sync

It's worth noting early on that Config Sync and Policy Controller are not a replacement for the CI/CD pipeline we set up in part 3 - these toolchains are complementary, and we'll actually see later in this demo how to apply Policy Controller checks to our existing CI/CD setup. Further, while Config Sync and CI/CD theoretically can handle all kinds of KRM config, a good rule of thumb is that Config Sync (cymbalbank-policy repo) is best used for policy configuration (eg. RBAC) and platform-level workloads (eg. Prometheus). Whereas CI/CD (cymbalbank-app-config repo) is best used for application workload config (eg. Deployments, Services). Plus we have application source code that lives in a totally separate repo (cymbalbank-app-source) and has no KRM of its own. 

The benefit of this setup is that all KRM lives in Git - so no matter what kind of resources live in each repo, we can see the Git commit history, add CI, and treat all of this configuration as code.

Let's explore how we can use Config Sync to keep the same resources constantly deployed across all three Cymbal Bank clusters.  

1. **Get the `frontend` namespace in the `cymbal-dev` cluster.** 
  
We created this namespace manually during part 1, but now it's being managed by Config Sync.  

```
kubectx cymbal-dev
kubectl get namespace frontend -o yaml 
```

Expected output: 

```
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    config.k8s.io/owning-inventory: config-management-system_root-sync
    configmanagement.gke.io/cluster-name: cymbal-dev
    configmanagement.gke.io/managed: enabled
```

You can see that a set of new `configmanagement` annotations have been added to the existing namespace, including  `configmanagement.gke.io/managed: enabled` which indicates that Config Sync is responsible for managing this resource, keeping it synced with the policy repo. 

Where did this resource come from? Let's explore the structure of the policy repo. 

2. **Run the `tree` command on the newly-initialized `cymbalbank-policy` repo.** 

```
tree cymbalbank-policy/
```

Expected output: 

```
cymbalbank-policy
├── README.md
└── namespaces
    ├── balancereader
    │   └── namespace.yaml
    ├── contacts
    │   └── namespace.yaml
    ├── frontend
    │   └── namespace.yaml
    ├── ledgerwriter
    │   └── namespace.yaml
    ├── loadgenerator
    │   └── namespace.yaml
    ├── transactionhistory
    │   └── namespace.yaml
    └── userservice
        └── namespace.yaml

8 directories, 8 files
```

This repo is what's called an **[unstructured](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/unstructured-repo)** repo in Config Sync. This means that we can set up the repo however we want to, with whatever subdirectory structure suits the Cymbal org best, and Config Sync will deploy all the resources in the subdirectories. The alternative for Config Sync is to use a **[hierarchical](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/concepts/hierarchical-repo)** repo, which has a structure you must adhere to (for instance, with cluster-scoped resources in a `cluster/` subdirectory).

By default, resources committed to a policy repo will be synced all clusters that use it as a sync source - so here, each of the Cymbal Bank namespaces we've committed will be synced to the dev, staging and prod clusters, because each of those clusters is set up to sync from this repo. 

We can also scope configs to only be applied to certain clusters. Let's see how.
