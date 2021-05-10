
## Part C - Creating Cluster-Scoped Resources 

![screenshot](screenshots/resourcequotas.jpg)

[Kubernetes Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/) help ensure that multiple tenants on one cluster - in our case, different Cymbal Bank services/app teams - don't clobber each other by eating up too many cluster resources, which can result in evicted pods and potential outages. For example purposes, we'll create this resource only in the `cymbal-prod` cluster, which we specify using the `cluster-name-selector` annotation below. This way, if our CD pipeline tries to deploy resources that violate the quota constraint, the prod cluster will not accept the resource, throwing a `403 - Forbidden` error.

The `production-quotas/` directory contains resource quotas for all Cymbal Bank app namespaces. 

1. **View the frontend Resource Quota YAML.** 

Each Cymbal Bank namespace will get one of these.  

```
cat production-quotas/frontend.yaml
```

Expected output: 

```YAML
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: frontend
  annotations:
    configsync.gke.io/cluster-name-selector: cymbal-dev
spec:
  hard:
    cpu: "100"
    memory: 10Gi
    pods: "10"
```

2. **Copy all the Resource Quota resources into your cloned policy repo.**

```
cp production-quotas/balancereader/quota.yaml cymbalbank-policy/namespaces/balancereader/
cp production-quotas/contacts/quota.yaml cymbalbank-policy/namespaces/contacts/
cp production-quotas/frontend/quota.yaml cymbalbank-policy/namespaces/frontend/
cp production-quotas/ledgerwriter/quota.yaml cymbalbank-policy/namespaces/ledgerwriter/
cp production-quotas/loadgenerator/quota.yaml cymbalbank-policy/namespaces/loadgenerator/
cp production-quotas/transactionhistory/quota.yaml cymbalbank-policy/namespaces/transactionhistory/
cp production-quotas/userservice/quota.yaml cymbalbank-policy/namespaces/userservice/
```

3. **Commit the ResourceQuotas to the `main` branch of the cymbalbank-policy repo.**

```
cd cymbalbank-policy/
git add .
git commit -m "Add ResourceQuotas"
git push origin main
```

Expected output: 

```
Writing objects: 100% (17/17), 1.45 KiB | 740.00 KiB/s, done.
Total 17 (delta 6), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (6/6), done.
To https://github.com/askmeegs/cymbalbank-policy
   e2bca67..cdfbaae  main -> main
```

4. **View the Config Sync status again.**

```
gcloud alpha container hub config-management status --project=${PROJECT_ID}
```

Expected output: 

```
Name            Status         Last_Synced_Token  Sync_Branch  Last_Synced_Time      Policy_Controller
cymbal-admin    NOT_INSTALLED  NA                 NA           NA                    NA
cymbal-dev      SYNCED         cdfbaae            main         2021-05-05T20:01:47Z  INSTALLED
cymbal-prod     SYNCED         cdfbaae            main         2021-05-05T20:01:39Z  INSTALLED
cymbal-staging  SYNCED         cdfbaae            main         2021-05-05T20:01:44Z  INSTALLED
```

Here the `Last_Synced_Token` should correspond to the Git commit sha from your latest commit to the policy repo, which you can find using `git log` or by navigating to the repo on Github. 


5. **Get the resource quotas on the prod cluster.** 

```
kubectx cymbal-prod
kubectl get resourcequotas --all-namespaces
```

Expected output: 

```
NAMESPACE                      NAME                  AGE     REQUEST                                                                                                                               LIMIT
balancereader                  gke-resource-quotas   26d     count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 1/1500, services: 1/500
balancereader                  production-quota      6m56s   cpu: 300m/700m, memory: 612Mi/512Mi
config-management-monitoring   gke-resource-quotas   5d1h    count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 1/1500, services: 1/500
config-management-system       gke-resource-quotas   4h16m   count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 4/1500, services: 1/500
contacts                       gke-resource-quotas   26d     count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 1/5k, pods: 1/1500, services: 1/500
contacts                       production-quota      6m56s   cpu: 300m/700m, memory: 164Mi/512Mi
...
```

You can see that every namespace as the `production-quota` we just committed, along with a default [GKE resource quota](https://cloud.google.com/kubernetes-engine/quotas#resource_quotas) which limits, for example, the total number of pods that can be deployed to each namespace. 

6. **Get the resource quotas on the dev cluster.** 
  
You should see only ResourceQuotas prefixed with `gke-`, and not the production-quotas. This is because we scoped the production quota resources to only be deployed to the `cymbal-prod` cluster. 

```
kubectx cymbal-prod
kubectl get resourcequotas --all-namespaces
```

7. **Return to the prod context and attempt to delete one of the ResourceQuotas manually.**

You should see an error, [which is ConfigSync saying, "only I can administer this resource"](https://cloud.google.com/anthos-config-management/docs/quickstart#attempt_to_manually_modify_a_managed_object). This enforcement helps you, the platform admin, avoid "configuration drift" (or "shadow ops") in your environment, where any Config Sync-managed resource cannot be deleted with kubectl, by you or anyone -- meaning that the live state of the resource should always reflect the committed resource in Git. 

```
kubectx cymbal-prod
kubectl delete resourcequota production-quota -n frontend
```

Expected output: 

```
error: You must be logged in to the server (admission webhook "v1.admission-webhook.configsync.gke.io" denied the request: requester is not authorized to delete managed resources)
```
