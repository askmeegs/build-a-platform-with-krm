![](screenshots/logo.png)

This repository contains the demos for the "Build a Platform with KRM" blog post + video series. 

These demos can be completed standalone - all you need is a Google Cloud project and a GitHub account. **[Get started here!](/1-setup)**

## What you'll build

![screenshot](screenshots/architecture.png)

## Contents 

### 🚧  [Demo 1 - Setup](/1-setup) 
- [1 - Setup](/1-setup)

### ☸️  [Demo 2 - How KRM Works](/2-how-krm-works) 
- [Part A - Setup](/2-how-krm-works/partA-setup.md)
- [Part B - Introducing the Kubernetes Resource Model](/2-how-krm-works/partB-introducing-krm.md)
- [Part C - The Cymbal Bank App](/2-how-krm-works/partC-cymbal-bank.md)
- [Part D - Deploying Cymbal Bank to GKE with Cloud Build](/2-how-krm-works/partD-cloud-build-cd.md)

### 💻  [Demo 3 - App Development with KRM](/3-app-dev) 
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

- [Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
- [Cloud Code](https://cloud.google.com/code)
- [Cloud Build](https://cloud.google.com/build)
- [Secret Manager](https://cloud.google.com/secret-manager)
- [Container Registry](https://cloud.google.com/container-registry)
- [Cloud SQL](https://cloud.google.com/sql/)
- [Config Sync](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/overview)
- [Policy Controller](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller) 
- [Config Connector](https://cloud.google.com/config-connector/docs/overview)
- [Compute Engine](https://cloud.google.com/compute/docs/quickstart-linux)
- [BigQuery](https://cloud.google.com/bigquery/docs/introduction)

### Open-Source 

- [Terraform](https://www.terraform.io/)
- [Github](https://github.com) 
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [skaffold](https://skaffold.dev)
- [kustomize](https://kustomize.io/)
- [Jib](https://github.com/GoogleContainerTools/jib)
- [Docker](https://www.docker.com/) 
- [OpenPolicyAgent](https://www.openpolicyagent.org/)
