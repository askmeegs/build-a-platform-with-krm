# ☸️  Intro to KRM 

This repo contains demos for the "Build a Platform with the Kubernetes Resource Model" content series. 

## Demo Architecture

![screenshot](screenshots/architecture.png)

## Contents 

1. [Setup](1/setup)
2. [How KRM Works](2-how-krm-works) 
3. [App Development with KRM](3-app-dev/)
4. [Administering KRM with Config Sync and Policy Controller](4-platform-admin/)
5. [Using KRM for Hosted Resources](5-hosted-resources/)

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

## Learn More

- [Kubernetes doc - What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)
- [Kubernetes docs - working with Kubernetes objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
- [Github - Kubernetes - the Kubernetes Resource Model](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/resource-management.md)
- [Kubernetes docs - kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [Github - jamiehannaford - what-happens-when-k8s](https://github.com/jamiehannaford/what-happens-when-k8s)
- [Google Cloud - GKE Cluster Architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture#control_plane)
- [Kubernetes Docs - Architecture - Controllers](https://kubernetes.io/docs/concepts/architecture/controller/)
- [Kustomize docs - Introduction](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [WeaveWorks Guide to GitOps](https://www.weave.works/technologies/gitops/)
- [Google Cloud Build - Deploying to GKE](https://cloud.google.com/build/docs/deploying-builds/deploy-gke)
- [Kustomize Documentation](https://kustomize.io/)
- [Examples - Kustomize](https://github.com/kubernetes-sigs/kustomize/tree/master/examples)
- [Kubernetes Docs - Mangaging Kubernetes Objects - Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Kustomize Tutorial](https://kubectl.docs.kubernetes.io/guides/config_management/components/)
- [Cloud Code Documentation](https://cloud.google.com/code/docs/vscode/setting-up-an-existing-app#setting_up_configuration_for_applications_that_already_have_skaffoldyaml)
- [Google Cloud - GitOps-style continuous delivery with Cloud Build](https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build)
- [Config Sync - Overview](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/config-sync-overview?hl=sv-SESee)
- [Config Sync samples](https://github.com/GoogleCloudPlatform/anthos-config-management-samples)
- [Config Sync - Configuring Only a Subset of Clusters](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/clusterselectors)
- [GKE Best practices - RBAC](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_namespaces_and_rbac_to_restrict_access_to_cluster_resources)
- [Policy Controller - Overview](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller)
- [Policy Controller - Creating Constraints using the default Constraint Template library](https://cloud.google.com/anthos-config-management/docs/how-to/creating-constraints)
- [Policy Controller - Writing Constraint Templates with Rego](https://cloud.google.com/anthos-config-management/docs/how-to/write-a-constraint-template)
- [OpenPolciyAgent - Gatekeeper - Docs](https://open-policy-agent.github.io/gatekeeper/website/docs/howto/)
- [OpenPolicyAgent - Rego language](https://www.openpolicyagent.org/docs/latest/policy-language/)
- [OpenPolicyAgent - The Rego Playground](https://play.openpolicyagent.org/)
- [Policy Controller - Using Policy Controller in a CI Pipeline](https://cloud.google.com/anthos-config-management/docs/tutorials/policy-agent-ci-pipeline)
- [Config Connector overview](https://cloud.google.com/config-connector/docs/overview)
- [List of Google Cloud resources supported by Config Connector](https://cloud.google.com/config-connector/docs/reference/overview)
- [Github - Config Connector samples](https://github.com/GoogleCloudPlatform/k8s-config-connector/tree/master/samples/resources)
- [`gcloud resource-config bulk-export](https://cloud.google.com/sdk/gcloud/reference/alpha/resource-config/bulk-export)
- [Google Cloud Blog - "Sign here! Creating a policy contract with Configuration as Data" - Kelsey Hightower and Mark Balch](https://cloud.google.com/blog/products/containers-kubernetes/how-configuration-as-data-impacts-policy)
- [Github - Config Connector + Policy Controller demo - Kelsey Hightower](https://github.com/kelseyhightower/config-connector-policy-demo) 
- [Google Cloud Architecture Center - Creating Policy-Compliant Cloud Resources](https://cloud.google.com/architecture/policy-compliant-resources)
- [Config Connector docs - Importing and exporting existing Google Cloud resources](https://cloud.google.com/config-connector/docs/how-to/import-export/export)
