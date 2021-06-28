![](screenshots/logo.png)

This repository contains the demos for the "Build a Platform with KRM" series.

These demos can be completed standalone - all you need is a Google Cloud project and a GitHub account. 

**[Get started here!](/1-setup)**

## What you'll build

![screenshot](screenshots/architecture.png)

## Contents 

⏱ **Note** - the estimated time to complete the demos is 9 hours. The demos do not have to be completed all at once, but each demo must be completed in order. 

### 🚧  [Demo 1 - Setup](/1-setup) (*[blog post](https://cloud.google.com/blog/topics/developers-practitioners/build-platform-krm-part-1-whats-platform)*) 
- [1 - Setup](/1-setup)

### ☸️  [Demo 2 - How KRM Works](/2-how-krm-works) (*[blog post](https://cloud.google.com/blog/topics/developers-practitioners/build-platform-krm-part-2-how-kubernetes-resource-model-works)*) 
- [Part A - Setup](/2-how-krm-works/partA-setup.md)
- [Part B - Introducing the Kubernetes Resource Model](/2-how-krm-works/partB-introducing-krm.md)
- [Part C - The Cymbal Bank App](/2-how-krm-works/partC-cymbal-bank.md)
- [Part D - Deploying Cymbal Bank to GKE with Cloud Build](/2-how-krm-works/partD-cloud-build-cd.md)

### 💻  [Demo 3 - App Development with KRM](/3-app-dev) (*[blog post](https://cloud.google.com/blog/topics/developers-practitioners/build-platform-krm-part-3-simplifying-kubernetes-app-development)*) 
- [Part A - Setup](/3-app-dev/partA-setup.md)
- [Part B - Add an Application Feature](/3-app-dev/partB-app-feature.md)
- [Part C - Test the feature](/3-app-dev/partC-test.md)
- [Part D - Create a Pull Request](/3-app-dev/partD-ci-pr.md)
- [Part E - Merge the Pull Request](/3-app-dev/partE-ci-main.md)
- [Part F - Continuous Deployment](/3-app-dev/partF-cd.md)
 
### 🛠  [Demo 4 - Administering KRM with Config Sync and Policy Controller](/4-platform-admin) 
- [Part A - Installing Config Sync and Policy Controller](/4-platform-admin/partA-installation.md)
- [Part B - Keeping Resources in Sync](/4-platform-admin/partB-configsync.md)
- [Part C - Creating Cluster-scoped Resources](/4-platform-admin/partC-cluster-scoped.md)
- [Part D - Using Policy Controller to Block External Services](/4-platform-admin/partD-policy-controller.md)
- [Part E - Creating Custom Policies](/4-platform-admin/partE-custom-policies.md)
- [Part F - Integrating Policy Checks into CI/CD](/4-platform-admin/partF-policy-check-ci.md)

### ☁️  [Demo 5 - Managing Cloud-hosted Resources with KRM](/5-hosted-resources) 
- [Part A - Introducing Config Connector](/5-hosted-resources/partA-config-connector.md)
- [Part B - Enforcing Policies on Cloud-Hosted Resources](5-hosted-resources/partB-cloud-policies.md)
- [Part C - Managing Existing Cloud Resources with Config Connector](/5-hosted-resources/partC-existing-resources.md)
- [Cleanup](https://github.com/askmeegs/build-a-platform-with-krm/blob/main/5-hosted-resources/partC-existing-resources.md#cleaning-up)

## Products and Tools Used

### Google Cloud 

- [BigQuery](https://cloud.google.com/bigquery/docs/introduction)
- [Cloud Build](https://cloud.google.com/build)
- [Cloud Code](https://cloud.google.com/code)
- [Cloud SQL](https://cloud.google.com/sql/)
- [Compute Engine](https://cloud.google.com/compute/docs/quickstart-linux)
- [Config Connector](https://cloud.google.com/config-connector/docs/overview)
- [Config Sync](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/overview)
- [Container Registry](https://cloud.google.com/container-registry)
- [Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
- [Policy Controller](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller) 
- [Secret Manager](https://cloud.google.com/secret-manager)

### Open-Source 
- [Kubernetes](https://kubernetes.io)
- [Docker](https://www.docker.com/) 
- [Github](https://github.com) 
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [kubectx](https://github.com/ahmetb/kubectx)
- [kustomize](https://kustomize.io/)
- [OpenPolicyAgent](https://www.openpolicyagent.org/)
- [skaffold](https://skaffold.dev)
- [Terraform](https://www.terraform.io/)
