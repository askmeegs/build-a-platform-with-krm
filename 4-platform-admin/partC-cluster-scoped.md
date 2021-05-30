
# Part C - Creating Cluster-Scoped Resources 

![screenshot](screenshots/resource-quotas.jpg)

[Kubernetes Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/) help ensure that multiple tenants on one cluster - in our case, different Cymbal Bank services/app teams - don't clobber each other by eating too many cluster resources. When one service uses too many resources, Kubernetes can evict pods in other namespaces, leading to potential outages. 

Let's set up Resource Quotas for the `cymbal-prod` cluster only. We do this using a [Config Sync feature](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/clusterselectors) called a `cluster-name-selector`. This is a piece of Kubernetes metadata we add to the KRM resource saying, "only deploy it to these clusters." Note that we're scoping the Resource Quotas to only one cluster here, but you can [scope resources to multiple clusters](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/clusterselectors#selecting_a_list_of_clusters) at once, too.

The `production-quotas/` directory contains resource quotas for all Cymbal Bank app namespaces. 

### 1. **View the frontend Resource Quota YAML.** Run this command from the `4-platform-admin/` directory.

Each Cymbal Bank namespace will get one of these.  

```bash
cat production-quotas/frontend/quota.yaml
```

Expected output: 

```YAML
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: frontend
  annotations:
    configsync.gke.io/cluster-name-selector: cymbal-prod
spec:
  hard:
    cpu: 700m
    memory: 512Mi
```

Here, we set resource quotas for CPU and Memory on the entire frontend namespace, meaning that in aggregate, all the Pods running in the frontend namespace must not use more than 700 CPU millicores, and 512 [mebibytes](https://medium.com/@betz.mark/understanding-resource-limits-in-kubernetes-memory-6b41e9a955f9) of memory.

### 2. **Copy all the Resource Quota resources into your cymbalbank-policy repo.**

```bash
cp production-quotas/balancereader/quota.yaml cymbalbank-policy/namespaces/balancereader/
cp production-quotas/contacts/quota.yaml cymbalbank-policy/namespaces/contacts/
cp production-quotas/frontend/quota.yaml cymbalbank-policy/namespaces/frontend/
cp production-quotas/ledgerwriter/quota.yaml cymbalbank-policy/namespaces/ledgerwriter/
cp production-quotas/loadgenerator/quota.yaml cymbalbank-policy/namespaces/loadgenerator/
cp production-quotas/transactionhistory/quota.yaml cymbalbank-policy/namespaces/transactionhistory/
cp production-quotas/userservice/quota.yaml cymbalbank-policy/namespaces/userservice/
```

### 3. **Commit the ResourceQuotas to the `main` branch of the cymbalbank-policy repo.**

```bash
cd cymbalbank-policy/
git add .
git commit -m "Add ResourceQuotas"
git push origin main
```

Expected output: 

```bash
Writing objects: 100% (17/17), 1.45 KiB | 740.00 KiB/s, done.
Total 17 (delta 6), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (6/6), done.
To https://github.com/askmeegs/cymbalbank-policy
   e2bca67..cdfbaae  main -> main
```

### 4. **View the Config Sync status again. You should see the clusters all move from `PENDING` to `SYNCED`, at a new git commit token.**

```bash
gcloud alpha container hub config-management status --project=${PROJECT_ID}
```

Expected output: 

```bash
Name            Status  Last_Synced_Token  Sync_Branch  Last_Synced_Time      Policy_Controller
cymbal-admin    SYNCED  061f56a            main         2021-05-13T23:41:13Z  INSTALLED
cymbal-dev      SYNCED  061f56a            main         2021-05-13T23:41:11Z  INSTALLED
cymbal-prod     SYNCED  061f56a            main         2021-05-13T23:41:12Z  INSTALLED
cymbal-staging  SYNCED  061f56a            main         2021-05-13T23:41:14Z  INSTALLED
```

### 5. **Get the resource quotas on the prod cluster.** 

```bash
kubectx cymbal-prod
kubectl get resourcequotas --all-namespaces
```

Expected output: 

```bash
NAMESPACE                      NAME                  AGE     REQUEST                                                                                                                               LIMIT
balancereader                  gke-resource-quotas   26d     count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 1/1500, services: 1/500
balancereader                  production-quota      6m56s   cpu: 300m/700m, memory: 612Mi/512Mi
...
```

You can see that every namespace has the `production-quota` we just committed, along with a default [GKE resource quota](https://cloud.google.com/kubernetes-engine/quotas#resource_quotas) which limits, among other things, the total number of pods that can be deployed to each namespace. 

### 6. **Get the resource quotas on the dev cluster.** 
  
```bash
kubectx cymbal-dev
kubectl get resourcequotas --all-namespaces
```

Expected output: 

```bash
Switched to context "cymbal-dev".
NAMESPACE                      NAME                  AGE    REQUEST                                                                                                                               LIMIT
balancereader                  gke-resource-quotas   3d     count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 1/1500, services: 1/500
config-management-monitoring   gke-resource-quotas   93m    count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 1/1500, services: 1/500
config-management-system       gke-resource-quotas   93m    count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 4/1500, services: 1/500
```

You should see only ResourceQuotas prefixed with `gke-`, and not the production-quotas. This is because we scoped the production quota resources to only be deployed to the `cymbal-prod` cluster. 

Nice! You just learned how to set up fine-grained, cluster-specific resource syncing for your GKE environment. 

Now let's explore the other KRM tool we just installed, Policy Controller. 

### **[Continue to Part D.](partD-policy-controller.md)**