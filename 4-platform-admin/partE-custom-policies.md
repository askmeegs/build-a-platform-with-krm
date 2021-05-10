
## Part E - Creating a Custom Constraint Template with Rego 

In addition to the built-in Constraint Template library provided by PolicyController, you can also create [custom Constraint Templates](https://cloud.google.com/anthos-config-management/docs/how-to/write-a-constraint-template) with your own org-specific logic.  These policies don't just have to be related to compliance - they can be arbitrary business logic too, or platform requirements defined within Cymbal Bank.

In this section, we'll write a custom Constraint Template that limits the total number of containers per pod to a set number. We'll then create a Constraint, using that template, that limits the number of containers to **2** per pod. There are certain valid use cases for adding additional ["sidecar" containers](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/) in a Pod, particularly when for example, Cymbal Bank already attaches the [Cloud SQL proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy) container to each backend service, allowing for secure communication to the databases.

But too many containers packed into one Pod can increase the risk of outages - when one container crashes, the whole pod crashes - and it allows for less horizontal scaling (if 1 container in a pod exceeds its resource requirements, the entire pod must be replicated, even if the other container doesn't need to be replicated). To guard against this, we'll create a Constraint Template to enforce the number of containers allowed per Pod, across all the Cymbal Bank GKE clusters. 

![screenshot](screenshots/num-allowed-containers.png)


**1. View the custom Constraint Template resource, which has been provided for you in the `constraint-limit-containers/` subdirectory.** 

```
cat constraint-limit-containers/constrainttemplate.yaml 
```

Expected output: 

```
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8slimitcontainersperpod
spec:
  crd:
    spec:
      names:
        kind: K8sLimitContainersPerPod
      validation:
        openAPIV3Schema:
          properties:
            allowedNumContainers:
              type: integer
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8slimitcontainersperpod

        numTemplateContainers := count(input.review.object.spec.template.spec.containers)
        numRunningContainers := count(input.review.object.spec.containers)
        containerLimit := input.parameters.allowedNumContainers

        template_containers_over_limit = true {
          numTemplateContainers > containerLimit
        }

        running_containers_over_limit = true {
          numRunningContainers > containerLimit
        }

        violation[{"msg": msg}] {
          template_containers_over_limit
          msg := sprintf("Number of containers in template (%v) exceeds the allowed limit (%v)", [numTemplateContainers, containerLimit])
        }

        violation[{"msg": msg}] {
          running_containers_over_limit
          msg := sprintf("Number of running containers (%v) exceeds the allowed limit (%v)", [numRunningContainers, containerLimit])
        }
```

This resource might look a little scary or unfamiliar, so let's unpack how this template works.  PolicyController Constraint Templates are written in a programming language called [Rego](https://www.openpolicyagent.org/docs/latest/policy-language/). Unlike raw KRM, which is OpenAPI-compliant JSON or YAML, Rego is a full-featured programming language, created by the [OpenPolicyAgent](https://www.openpolicyagent.org/) project. Rego is a query language designed specifically for creating policies. Rego [supports](https://www.openpolicyagent.org/docs/latest/policy-reference/) objects, arrays, conditionals, functions, regular expressions, and other general-purpose language features, but it's structured differently from a language like Python or Java in that it's designed to take [some inputs (in our case, a KRM resource)](https://www.openpolicyagent.org/docs/latest/kubernetes-primer/#input-document), reason about the contents of that resource, and return an output, ultimately a boolean value - should this KRM resource be allowed into the cluster, or not?

So you can think of Rego code as statements that are evaluated from top to bottom, with a conclusion made at the end. In the ConstraintTemplate above, for example, the following statement is a conditional setting `template_containers_over_limit` to `true` **if** `numTemplateContainers` is greater than `containerLimit`. Then in the `violation` below that, the statement `template_containers_over_limit` actually means, **if** `template_containers_over_limit` is `true`, **then** throw the policy violation `msg` and reject the resource for defining too many containers per pod. 

```
  template_containers_over_limit = true {
    numTemplateContainers > containerLimit
  }
```
Overall, if we look at a Kubernetes resource and evaluate the intended number of containers per pod, and the number of running containers per pod, and decide that they're both within the allowed number, we throw no policy `violations`. This is what the Policy Controller pod (`gatekeeper`) will do automatically for every resource coming into any of the clusters. 

**2. View the Constraint, which implements the `K8sLimitContainersPerPod` Constraint Template.** 

```
cat constraint-limit-containers/constraint.yaml 
```

Expected output: 

```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sLimitContainersPerPod
metadata:
  name: limit-three-containers
spec:
  parameters:
    allowedNumContainers: 3
```

Note that this constraint has no `cluster-selector` annotations, so Config Sync will apply it to all of the clusters. 

**3. Commit both resources to the cymbalbank-policy repo.** 

```
cp constraint-limit-containers/constrainttemplate.yaml cymbalbank-policy/clusters/
cp constraint-limit-containers/constraint.yaml cymbalbank-policy/clusters/
cd cymbalbank-policy/
git add .
git commit -m "Add Constraint Template - K8sLimitContainersPerPod"
git push origin main
cd ..
```

**4. Return to the dev cluster. Verify that the second Constraint, `limit-two-containers`, has been created.** 

```
kubectx cymbal-dev
kubectl get constraint
```

Expected output: 

```
NAME                                                                  AGE
k8snoexternalservices.constraints.gatekeeper.sh/dev-no-ext-services   8h

NAME                                                                      AGE
k8slimitcontainersperpod.constraints.gatekeeper.sh/limit-two-containers   3m42s
```

**5. View the test workload.**

This is a Deployment where each Pod has 4 containers, each running `nginx`. 4 containers exceeds our limit of 23 containers per pod, so we would expect Policy Controller to reject this resource. 

```
cat constraint-limit-containers/test-workload.yaml
```

Expected output: 

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1 
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx1
        image: nginx:1.14.2
        ports:
        - containerPort: 8080
      - name: nginx2
        image: nginx:1.14.2
        ports:
        - containerPort: 8081
      - name: nginx3
        image: nginx:1.14.2
        ports:
        - containerPort: 8082
      - name: nginx4
        image: nginx:1.14.2
        ports:
        - containerPort: 8084
```

**6. Attempt to apply the test workload to the dev cluster.**

You should see an error message. 

```
kubectl apply -f constraint-limit-containers/test-workload.yaml
```

Expected output: 

```
TODO
```

**Well done!** You just used the Rego policy language to deploy your own custom policy for the Cymbal Bank platform. 

