# Part 5 - Using KRM for Hosted Resources 

In part 2, we learned about the Controller model in Kubernetes, where your desired state - applied to the Kubernetes API Server - is "actuated" upon, or "made real," with a bunch of Controllers. These controllers do things like generate Pods and create Services inside that cluster. You can look at the [source code](https://github.com/kubernetes/kubernetes/blob/master/pkg/controller) for the open source Kubernetes controllers - [here's the one for ReplicaSets (Deployments)](https://github.com/kubernetes/kubernetes/blob/master/pkg/controller/replicaset/replica_set.go). 

But even though the API Server and the Kubernetes Controllers are closely connected, they're actually two separate things. The API Server is what allows you to define KRM, as YAML files, and use the toolchain we've explored throughout these demos -- kustomize, Cloud Code, skaffold, Cloud Build, Config Sync, Policy Controller. The Controllers are the internals, and they're just Go code. 

This separation of components has exciting implications. It means that the Kubernetes API is extensible such that anyone can write a [custom controller](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#custom-controllers), and along with that controller, Custom Resource Definitions as KRM. Meaning you can have custom logic that says, "for this kind of YAML file, do this." The [Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) pattern is a common way to implement this in Kubernetes. 

Because controller logic can do anything with a KRM resource, Cloud Providers have actually started to write controllers for their own hosted resources. Meaning, provide Kubernetes Custom Resources for their own hosted resources - think [AWS S3 buckets](https://aws-controllers-k8s.github.io/community/services/#amazon-s3) or an [Azure virtual network](https://github.com/Azure/azure-service-operator/blob/master/docs/services/virtualnetwork/virtualnetwork.md). There are even projects like [Crossplane](https://crossplane.io) that provide KRM resources and controllers for multiple cloud providers at once.  

In this model, the desired state lives in Kubernetes, but the actual state lives elsewhere - inside the cloud provider's data centers. 

In this final demo, we will learn how to lifecycle Google Cloud-hosted resources with KRM, using a tool called [Config Connector](https://cloud.google.com/config-connector/docs/overview).

## What you'll learn 

- The benefits of using KRM to manage cloud-hosted resources
- How to spin up a Google Compute Engine instance using Config Connector
- How to integrate Policy Controller with cloud-hosted resources like BigQuery
- How to export live-running GCP resources as KRM
- How to manage existing cloud resources using Config Connector  

**[Continue to Part A - Introducing Config Connector.](partA-config-connector.md)**