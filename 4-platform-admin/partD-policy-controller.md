
## Part D - Using Policy Controller to Block External Services 

Now that we've learned how to use Config Sync to make sure certain resources are deployed consistently across our Kubernetes environment (our first goal), let's address the second goal: preventing unsafe configuration from landing in any of the clusters. 

Up to now, we've used Config Sync to deploy resources that are part of the Kubernetes core APIs (Namespaces, ResourceQuotas). And while those core APIs support several resources that help prevent bad actors from deploying resources, we can actually sync custom policies using a tool called [Policy Controller](). Policy Controller is a Google-managed [Kubernetes admission controller](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller) that can enforce arbitrary "constraints" related to security and compliance. 

Let's unpack that. An **admission controller** is a pod that sits at the "gate" of a Kubernetes cluster, watching what's coming into the API server and doing some type of operation on that resource, before it's persisted in etcd. That could include modifying the resource in-flight ([MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook)) or rejecting the resource entirely ([ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook)). Policy Controller uses the second kind of webhook to validate incoming config against the policies it knows about. Policy Controller is based on an open-source project called [Gatekeeper](https://github.com/open-policy-agent/gatekeeper#gatekeeper), which in turn grew out of the [OpenPolicyAgent](https://www.openpolicyagent.org/) project, part of the [CNCF](https://www.cncf.io/). 

So what do those policy "constraints" look like? What kinds of Kubernetes resources can we use PolicyController to accept or reject? 

Policy Controller comes with a set of [default constraint templates](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library). These templates can do things like [block RBAC resources from using wildcards](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8sprohibitrolewildcardaccess) (preventing sweeping access to many resources at once), [block privileged containers](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8spspallowprivilegeescalationcontainer), and require all pods to have [Liveness probes](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8srequiredprobes), a feature that helps avoid outages by restarting Pods stuck in deadlock or similar dying states.  

In this demo, we're going to create a policy for the `cymbal-dev` cluster that [blocks the creation of external services](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8snoexternalservices). This will help ensure that no sensitive code in development is exposed to the public.  

![screenshot](screenshots/block-ext-services.jpg)

1. **Switch to the `cymbal-dev` cluster, and verify that the Constraint Template library is installed.** 
  
This is a set of a few dozen Custom Resources (CRDs), each defining a ConstraintTemplate.   

```
kubectl get constrainttemplates \
    -l="configmanagement.gke.io/configmanagement=config-management"
```

Expected output: 

```
NAME                                      AGE
allowedserviceportname                    2d9h
destinationruletlsenabled                 2d9h
disallowedauthzprefix                     2d9h
gcpstoragelocationconstraintv1            2d9h
k8sallowedrepos                           2d9h
...
```

2. **View the `K8sNoExternalServices` Constrant resource, provided for you in the `constraint-ext-services` directory.** 

This Constraint implements the `[K8sNoExternalServices](https://cloud.google.com/anthos-config-management/docs/reference/constraint-template-library#k8snoexternalservices)` Constraint Template with concrete information about our environment. 

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

**3. Create a new subdirectory in the `policy-repo`, `clusters/cymbal-dev`.**

This is where we'll keep cluster-wide policies, separate from namespace-specific directories. 

```
mkdir -p cymbalbank-policy/clusters/cymbal-dev
```

**4. Copy `constraint.yaml` into the new directory.**

```
cp constraint-ext-services/constraint.yaml cymbalbank-policy/clusters/cymbal-dev/
```

**5. Commit the Constraint to the main branch of the policy repo.**

```
cd cymbalbank-policy 
git add .
git commit -m "Policy Controller - Add K8sNoExternalIP Constraint"
git push origin main 
cd .. 
```

**6. Verify that the policy has been synced to the `cymbal-dev` cluster.**

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

**7. Verify that the constraint is deployed to the cymbal-dev cluster.** 

```
kubectl get constraint 
```

Expected output: 

```
 NAME                                                                  AGE
k8snoexternalservices.constraints.gatekeeper.sh/dev-no-ext-services   47s
```

**8. Attempt to manually create a service type LoadBalancer in the `cymbal-dev` cluster, corresponding to the `contacts` service Deployment.**
  
You should get an error stating that the Policy Controller admission webhook is blocking the incoming resource. 

```
kubectl apply -f constraint-ext-services/contacts-svc-lb.yaml
```

Expected output: 

```
Resource: "/v1, Resource=services", GroupVersionKind: "/v1, Kind=Service"
Name: "contacts", Namespace: "contacts"
for: "constraint-ext-services/contacts-svc-lb.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by dev-no-ext-services] Creating services of type `LoadBalancer` without Internal annotation is not allowed
```

**Congrats**! You just deployed your first Policy Controller policy via Config Sync. Policies like this can help platform admins reach the second goal discussed at the beginning of this demo, which is to monitor and prevent unsafe KRM in our environment.  
