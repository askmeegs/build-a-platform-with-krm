# 4 - Admin Workflow with Config Sync and Policy Controller

## Contents 

## What you'll learn 

- How GitOps promotes SecOps best practices 
- How to use Config Sync to sync KRM from Github to multiple GKE clusters
- When to use Config Sync for KRM, vs. CI/CD 
- How to scope resources to only apply to the dev or prod environments 
- How Policy Controller promotes compliance in a Kubernetes environment
- How to use Policy Controller to define org-wide policies, synced with ConfigSync.

## Prerequisites 

Completed parts 1-3. 

## Introduction 

In [part 2](/2-how-krm-works), we learned how the Kubernetes API works, and how to apply resources with `kubectl apply -f`. Then in [part 3](/3-app-dev), we learned how to set up automation around deploying KRM resources using CI/CD, skaffold, and kustomize. 

These two use cases cover Kubernetes app development use cases well. But now imagine that you're a platform developer or administrator, responsible not just for one of the CymbalBank services, but for the entire Kubernetes environment, including the `dev`, `staging`, and `prod` clusters. An app developer may care most about testing their code and getting features into production with minimal friction, but your concerns are probably different. You care about consistency across the whole platform - that certain baseline resources are always deployed and in sync across all the clusters. (You do *not* want a developer to `kubectl apply -f` one of those resources by mistake, and you especially don't want that to happen without anyone knowing.) You also care about compliance with the financial services regulations CymbalBank is subject to, and you might work directly with Cymbal's security and compliance team to make sure the necessary policies are in place. 

So if I'm a platform admin, I really care about two things with KRM: 1) Consistency, and 2) Protect the clusters from unsafe configuration. This demo explores how two Google Cloud tools - **Config Sync** and **Policy Controller** - help platform admins accomplish those two goals. 

## Part A - Install Config Sync and Policy Controller 

![screenshot](screenshots/sync-overview.png)

1. Set variables. 

```
export PROJECT_ID=[your-project-id]
```

2. Initialize the policy repo you created during setup. This repo is located at `github.com/YOUR-USERNAME/cymbalbank-policy` and it's currently empty. This script populates the repo with namespaces corresponding to each of the CymbalBank services. These namespaces were created manually during setup, initially. Now we're preparing to bringing those namespaces into Config Sync's management domain, guarding against manual editing or deletion.   

```
./policy-repo-setup.sh
```

3. Install ConfigSync on the dev, staging, and prod clusters. **TODO** - currently not using this script because PC stuck in pending. Using UI install to install both CS and PC at once. 


```
./install.sh
```

4. Get the install status for all clusters in your project. 

```
gcloud alpha container hub config-management status --project=${PROJECT_ID}
```

Expected output: 

```
Name            Status         Last_Synced_Token  Sync_Branch  Last_Synced_Time      Policy_Controller
cymbal-admin    NOT_INSTALLED  NA                 NA           NA                    NA
cymbal-dev      SYNCED         e2bca67            main         2021-05-05T15:50:00Z  INSTALLED
cymbal-prod     SYNCED         e2bca67            main         2021-05-05T15:54:08Z  INSTALLED
cymbal-staging  SYNCED         e2bca67            main         2021-05-05T15:53:29Z  INSTALLED
```

Notice that each of the `cymbal-dev`, `cymbal-staging`, and `cymbal-prod` clusters are synced to the same commit of the same repo - this is the first step towards consistent config across the GKE environment. 

## Part B - Administering KRM with Config Sync

It's worth noting early on that Config Sync/Policy Controller are not a replacement for the CI/CD pipeline we set up in part 3 - these toolchains are complementary, and we'll actually see later in this demo how to apply Policy Controller checks to our existing CI/CD setup. Further, while Config Sync and CI/CD theoretically can handle all kinds of KRM config, a good rule of thumb is that Config Sync (cymbalbank-policy repo) is best used for policy configuration (eg. RBAC) and platform-level workloads (eg. Prometheus). Whereas CI/CD (cymbalbank-app-config repo) is best used for application workload config (eg. Deployments, Services). Plus we have application source code that lives in a totally separate repo (cymbalbank-app-source) and has no KRM of its own. 

The benefit of this setup is that all KRM lives in Git - so no matter what kind of resources live in each repo, we can see the Git commit history, add CI, and treat all of this KRM as code.

Let's explore the "platform level configuration" we can deploy via Config Sync to achieve consistency across all the GKE clusters. 

1. Get the `frontend` namespace in the `cymbal-dev` cluster. We created this namespace manually during part 1, but now it's being managed by Config Sync.  

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

Where did this resource come from? 

2. Explore the structure of the policy repo by running the `tree` command. 

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

This repo is what's called an **[unstructured](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/unstructured-repo)** repo in Config Sync. This means that we can set up the repo however we want to, with whatever subdirectory structure suits the Cymbal org best, and Config Sync will. The alternative for Config Sync is to use a **[hierarchical](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/concepts/hierarchical-repo)** repo, which has a structure you must adhere to (for instance, with cluster-scoped resources in a `cluster/` subdirectory).

By default, resources committed to a policy repo will be synced all clusters that use it as a sync source - so here, each of the Cymbal Bank namespaces we've committed will be synced to the dev, staging and prod clusters, because each of those clusters is set up to sync from this repo. 

We can also scope configs to only be applied to certain clusters. Let's see how.

## Part C - Creating Cluster-Scoped Resources 

![screenshot](screenshots/resourcequotas.png)

[Kubernetes Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/) help ensure that multiple 'tenants' on one cluster - in our case, different Cymbal Bank services - don't clobber each other by eating up too many cluster resources, which can result in evicted pods and potential outages. For example purposes, we'll create this resource only in the `cymbal-prod` cluster, which we specify using the `cluster-name-selector` annotation below. This way, if our CD pipeline tries to deploy resources that violate the quota constraint, the prod cluster will not accept the resource, throwing a `403 - Forbidden` error.

The `production-quotas/` directory contains resource quotas for all Cymbal Bank app namespaces. 

1. View the frontend Resource Quota YAML. 

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

2. Copy all the Resource Quota resources into your cloned policy repo.

```
cp production-quotas/balancereader/quota.yaml cymbalbank-policy/namespaces/balancereader/
cp production-quotas/contacts/quota.yaml cymbalbank-policy/namespaces/contacts/
cp production-quotas/frontend/quota.yaml cymbalbank-policy/namespaces/frontend/
cp production-quotas/ledgerwriter/quota.yaml cymbalbank-policy/namespaces/ledgerwriter/
cp production-quotas/loadgenerator/quota.yaml cymbalbank-policy/namespaces/loadgenerator/
cp production-quotas/transactionhistory/quota.yaml cymbalbank-policy/namespaces/transactionhistory/
cp production-quotas/userservice/quota.yaml cymbalbank-policy/namespaces/userservice/
```

3. Commit the ResourceQuotas to the main branch of the cymbalbank-policy repo. 

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

4. View the sync status. The `Last_Synced_Token` should correspond to the Git commit sha from your latest commit to the policy repo, which you can find using `git log` or by navigating to the repo on Github. 

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

5. Get the resource quotes on the prod cluster. 

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

6. Try to get the same set of resources on the cymbal-dev cluster. You should see only ResourceQuotas prefixed with `gke-`, and not the production-quotas. This is because we scoped the production quota resources to only be deployed to the `cymbal-prod` cluster. 

```
kubectx cymbal-prod
kubectl get resourcequotas --all-namespaces
```

7. Return to the prod context and attempt to delete one of the ResourceQuotas manually. You should see an error, [which is ConfigSync saying, "only I can administer this resource"](https://cloud.google.com/anthos-config-management/docs/quickstart#attempt_to_manually_modify_a_managed_object). This enforcement helps you, the platform admin, avoid "configuration drift" (or "shadow ops") in your environment, where any Config Sync-managed resource cannot be deleted with kubectl, by you or anyone -- meaning that the live state of the resource should always reflect the committed resource in Git. 

```
kubectx cymbal-prod
kubectl delete resourcequota production-quota -n frontend
```

Expected output: 

```
error: You must be logged in to the server (admission webhook "v1.admission-webhook.configsync.gke.io" denied the request: requester is not authorized to delete managed resources)
```

## Part C - Using Policy Controller to Block External Services 

Now that we've learned how to use Config Sync to make sure certain resources are deployed consistently across our Kubernetes environment (our first goal), let's address the second goal: preventing unsafe configuration from landing in any of the clusters. 

Up to now, we've used Config Sync to deploy resources that are part of the Kubernetes core APIs (Namespaces, ResourceQuotas). And while those core APIs support several resources that help prevent bad actors from deploying resources, we can actually sync custom policies using a tool called [Policy Controller](). Policy Controller is a Google-managed [Kubernetes admission controller](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller) that can enforce arbitrary "constraints" related to security and compliance. 

Let's unpack that. An **admission controller** is a pod that sits at the "gate" of a Kubernetes cluster, watching what's coming into the API server and doing some type of operation on that resource, before it's persisted in etcd. That could include modifying the resource in-flight ([MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook)) or rejecting the resource entirely ([ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook)). Policy Controller uses the second kind of webhook to validate incoming config against the policies it knows about. Policy Controller is based on an open-source project called [Gatekeeper](https://github.com/open-policy-agent/gatekeeper#gatekeeper), which in turn grew out of the [OpenPolicyAgent](https://www.openpolicyagent.org/) project, part of the [CNCF](https://www.cncf.io/). 

So what do those policy "constraints" look like? What kinds of Kubernetes resources can we use PolicyController to accept or reject? 

Policy Controller comes with a set of [default constraint templates](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library). These templates can do things like [block RBAC resources from using wildcards](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8sprohibitrolewildcardaccess) (preventing sweeping access to many resources at once), [block privileged containers](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8spspallowprivilegeescalationcontainer), and require all pods to have [Liveness probes](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8srequiredprobes), a feature that helps avoid outages by restarting Pods stuck in deadlock or similar dying states.  

In this demo, we're going to create a policy for the `cymbal-dev` cluster that [blocks the creation of external services](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8snoexternalservices). This will help ensure that no sensitive code in development is exposed to the public.  

![screenshot](screenshots/policycontroller.png)

1. Switch to the `cymbal-dev` cluster, and verify that the Constraint Template library is installed. This is a set of Custom Resources (CRDs), each defining a ConstraintTemplate.   

2. View the `K8sNoExternalServices` Constrant resource, provided for you in the `constraint-ext-services` directory. This Constraint implements the `[K8sNoExternalServices](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8snoexternalservices)` Constraint Template with concrete information about our environment. 

```
cat constraint-ext-services/constraint.yaml
```

Expected output: 

```YAML 
# Blocks the creation of Ingress and Service type=LoadBalancer resources 
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sNoExternalServices
metadata:
  name: dev-no-ext-services
  annotations:
    configsync.gke.io/cluster-name-selector: cymbal-dev
spec:
  internalCIDRs: []
```

Notice how again, we're using Config Sync's `cluster-name-selector` annotation to scope this resource to the `cymbal-dev` cluster only.

1. Create a new subdirectory in the `policy-repo`, `clusters/cymbal-dev`. This is where we'll keep cluster-wide policies, separate from namespace-specific directories. 

```
mkdir -p cymbalbank-policy/clusters/cymbal-dev
```

1. Copy `constraint.yaml` into the new directory. 

```
cp constraint-ext-services/constraint.yaml cymbalbank-policy/clusters/cymbal-dev/
```

1. Commit the resource 

```
cd cymbalbank-policy 
git add .
git commit -m "Policy Controller - Add K8sNoExternalIP Constraint"
git push origin main 
cd .. 
```

1. Verify that the policy has been synced to the `cymbal-dev` cluster using Config Sync. 

```
gcloud alpha container hub config-management status --project=${PROJECT_ID}
```

Expected output: 

```
Name            Status         Last_Synced_Token  Sync_Branch  Last_Synced_Time      Policy_Controller
cymbal-admin    NOT_INSTALLED  NA                 NA           NA                    NA
cymbal-dev      SYNCED         9ddcede            main         2021-05-06T15:25:38Z  INSTALLED
cymbal-prod     SYNCED         9ddcede            main         2021-05-06T15:25:41Z  INSTALLED
cymbal-staging  SYNCED         9ddcede            main         2021-05-06T15:25:40Z  INSTALLED
```

1. Verify that the constraint is deployed to the cymbal-dev cluster. 

```
kubectl get constraint 
```

Expected output: 

```
 NAME                                                                  AGE
k8snoexternalservices.constraints.gatekeeper.sh/dev-no-ext-services   47s
```

2. Attempt to manually create a service type LoadBalancer in the `cymbal-dev` cluster, corresponding to the `contacts` service Deployment. You should get an error stating that the Policy Controller admission webhook is blocking the incoming resource. 

```
kubectl apply -f constraint-ext-services/contacts-svc-lb.yaml
```

Expected output: 

```
Resource: "/v1, Resource=services", GroupVersionKind: "/v1, Kind=Service"
Name: "contacts", Namespace: "contacts"
for: "constraint-ext-services/contacts-svc-lb.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by dev-no-ext-services] Creating services of type `LoadBalancer` without Internal annotation is not allowed
```

Congrats! You just deployed your first Policy Controller policy via Config Sync. Policies like this can help platform admins reach the second goal discussed at the beginning of this demo, which is to monitor and prevent unsafe KRM in our environment.  

## Part D - Enforcing Custom Policies with OPA and Rego 

In addition to the built-in Constraint Template library provided by PolicyController, you can also create custom policies with your own org-specific logic.  These policies don't just have to be related to compliance - they can be arbitrary business logic too, or platform requirements defined within Cymbal Bank. For example, let's create a policy that 

![screenshots](custom-policy.png)


## Part E - Integrating Policy Controller with CI/CD 

https://cloud.google.com/anthos-config-management/docs/tutorials/policy-agent-ci-pipeline#unstructured_1

https://cloud.google.com/anthos-config-management/docs/tutorials/app-policy-validation-ci-pipeline

Policy Controller provides 
But by default, it only enforces those policies at runtime - said another way, Policy Controller can only "catch" (and subsequently block) an out-of-policy resource as it enters the cluster. As a platform admin, ideally I want multiple layers of enforcement, so that a developer knows if their resources are non-compliant, and can fix them before merging them into repo.  

Let's see how to integrate policy checks into the app-config-repo CI/CD pipeline, to vet the Cymbal Bank app KRM against the policies we set up in the previous sections. 



## Learn More 

### Config Sync 

- [Config Sync documentation](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/config-sync-overview?hl=sv-SESee)
- [Config Sync samples](https://github.com/GoogleCloudPlatform/anthos-config-management-samples)
- [Config Sync - Configuring Only a Subset of Clusters](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/clusterselectors)
- [GKE Best practices - RBAC](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_namespaces_and_rbac_to_restrict_access_to_cluster_resources)


### Policy Controller

- [Policy Controller documentation](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller)
- [Policy Controller - Creating Constraints](https://cloud.google.com/anthos-config-management/docs/how-to/creating-constraints)