# Part A - Installing Config Sync and Policy Controller 

![screenshot](screenshots/sync-overview.jpg)

### 1. `cd` into the `4-platform-admin/` directory from the root of this repository. 

```
cd 4-platform-admin/
```

### 2. **Set variables.** 

```
export PROJECT_ID=[your-project-id]
export GITHUB_USERNAME=[your-github-username]
```

### 3. **Initialize the cymbalbank-policy repo**.

You created this Github repo in your account during setup. This repo is located at `github.com/YOUR-USERNAME/cymbalbank-policy` and it's currently empty. 

This script populates your policy repo with namespaces corresponding to each of the CymbalBank services. These namespaces were created with a [shell script in part 1](/1-setup/cluster-setup.sh), initially. Now we're preparing to bringing those namespaces into Config Sync's management domain, guarding against manual editing or deletion.   

Run the policy repo setup script from the `4-platform-admin/` directory: 

```
./policy-repo-setup.sh
```

Expected output: 

```
Compressing objects: 100% (9/9), done.
Writing objects: 100% (17/17), 1.29 KiB | 662.00 KiB/s, done.
Total 17 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/askmeegs/cymbalbank-policy
 * [new branch]      main -> main
```

### 4. **Install Config Sync and Policy Controller** on all four GKE clusters. 

```
./install.sh 
```

This script does the following: 

- Installs [Config Sync](https://cloud.google.com/anthos-config-management/docs/config-sync-overview) on all four clusters. This is a set of workloads, running in each cluster, designed to sync configuration from the policy repo to the cluster automatically. 
- Installs [Policy Controller](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller) on all four clusters. This is a Kubernetes admission controller that can read custom policies from your policy repo. 

### 5. **Get the Config Sync and Policy Controller install status for all clusters in your project.**

```
gcloud alpha container hub config-management status --project=${PROJECT_ID}
```

Expected output: 

```
Name            Status  Last_Synced_Token  Sync_Branch  Last_Synced_Time      Policy_Controller
cymbal-admin    SYNCED  5e068d0            main         2021-05-13T22:10:25Z  INSTALLED
cymbal-dev      SYNCED  5e068d0            main         2021-05-13T22:11:21Z  INSTALLED
cymbal-prod     SYNCED  5e068d0            main         2021-05-13T22:14:10Z  INSTALLED
cymbal-staging  SYNCED  5e068d0            main         2021-05-13T22:19:12Z  INSTALLED
```

Here, `Last_Synced_Token` is the git commit `SHORT_SHA` of your latest commit to the `main` branch of your `cymbalbank-policy` repo - you can verify this by `cd`-ing into your policy repo and running: 

```
git log 
```

Expected output: 

```
commit 5e068d0ff2128026368479342ff7f892dc964f8d (HEAD -> main, origin/main)
Author: askmeegs <megan037@gmail.com>
Date:   Thu May 13 17:58:10 2021 -0400

    Init - CymbalBank namespaces
```

So when you installed Config Sync and Policy Controller, what actually got deployed? 

### 6. **Switch to the dev cluster, and get the Pods in the `config-management-system` and `gatekeeper-system` namespaces.**

```
kubectx cymbal-dev
kubectl get pods -n config-management-system
kubectl get pods -n gatekeeper-system
```

Expected output: 

```
NAME                                          READY   STATUS    RESTARTS   AGE
admission-webhook-64948475d7-v27tr            1/1     Running   0          23m
admission-webhook-64948475d7-wtgls            1/1     Running   1          23m
config-management-operator-7d5f54c74c-k82g4   1/1     Running   0          24m
reconciler-manager-7c6dccbb5f-pp5w2           2/2     Running   0          23m
root-reconciler-699dbf97cb-xw8bh              4/4     Running   0          22m
NAME                                             READY   STATUS    RESTARTS   AGE
gatekeeper-audit-6f46754545-9zqh2                1/1     Running   0          23m
gatekeeper-controller-manager-7f778d8b94-jxxrq   1/1     Running   0          23m
```

The first set of workloads, in the `config-management-system` namespace, run Config Sync. These workloads periodically check your GitHub policy repo for any updates to the KRM source of truth stored there, and deploys those updated resources to the cluster. (Note that every cluster runs their own Config Sync, but all the clusters are synced to the same repo.)

The second set of workloads, in the `gatekeeper-system` namespace, run Policy Controller. (Policy Controller is based on an open-source project called [Gatekeeper](https://github.com/open-policy-agent/gatekeeper)). These workloads help ensure that any resources entering the cluster - both through CI/CD or through Config Sync - adheres with any policies we set. 

We'll explore how both these tools work in the rest of this demo. 

Now that all our clusters are synced to the same policy repo, we can get started on the first goal - ensuring KRM resource consistency across our multi-cluster environment. 

**[Continue to Part B - Keeping Resources in Sync.](partB-configsync.md)**
