# Part 5 - Using KRM for Hosted Resources 

## What you'll learn 

- Why you'd use the Kubernetes Resource Model to lifecycle resources outside of Kubernetes 


## Introduction 

Why KRM for cloud resources? 
- Frees you from gcloud / bash scripts 
- Unify K8s and non K8s resources into 1 repo, 1 format 
- GitOps + config sync for hosted resources ( > TF)
- Policy checks for hosted resources 

## Part A - Introducing Config Connector for Kubernetes
Why KRM for cloud resources? 
- Frees you from gcloud / bash scripts 
- Unify K8s and non K8s resources into 1 repo, 1 format 
- GitOps + config sync for hosted resources ( > TF)
- Policy checks for hosted resources 


Config Connector can be installed to GKE as a cluster add-on, on cluster creation, so config sync is already running on the Cymbal Admin cluster. You may have also noticed we didn't install Config Connector on any of the other clusters -- because Config Connector spawns Google Cloud resources outside the cluster, we want to avoid multiple copies of the same resource deployed into different clusters, to avoid clobbering. 

Basic example - create a Compute Engine instance. 


## Part B - Managing Existing Cloud Resources with Config Connector 

In this section, we'll bring our existing hosted Cloud SQL databases- originally created via Terraform, in part 1- into the management of Config Connector, via Config Sync. 

1. [Install the Config Connector tool](https://cloud.google.com/config-connector/docs/how-to/import-export/overview#installing-config-connector) and ensure it's in your PATH: 

```
config connector version
```

Expected output: 

```
1.46.0
```

1. Set variables. 

```
export PROJECT_ID=[your-project-id]
```

1. Get the Config Connector pods in the `cnrm-system` namespace. ("CNRM" stands for "Cloud Native Resource Management" and was an earlier product name for Config Connector.) 

```
kubectx cymbal-admin 
kubectl get pods -n cnrm-system
```

Expected output: 

```
NAME                                            READY   STATUS    RESTARTS   AGE
cnrm-deletiondefender-0                         1/1     Running   0          10h
cnrm-resource-stats-recorder-68648fd95d-9k2hc   2/2     Running   0          10h
cnrm-webhook-manager-7d5b995bbc-4dcv4           1/1     Running   0          10h
cnrm-webhook-manager-7d5b995bbc-pxkkq           1/1     Running   0          10h
```

1. Clone the cymbalbank-policy repo in this directory, and create a "clusters/cymbal-admin" directory.

```
git clone https://github.com/cymbalbank-policy
mkdir -p cymbalbank-policy/clusters/cymbal-admin
```

1. View the resources in the `cloudsql-source` directory. 

1. Copy the resources in the `cloudsql-source` directory into the cymbalbank-policy repo.  

1. Commit the Cloud SQL resources to the cymbalbank-policy repo's `main` branch. 

1. Wait for Config Sync to sync the Cloud SQL resources down to the admin cluster. 

1. Get the resources managed by Config Connector. 

```
kubectl get gcp
```

1. Get the sync status for the dev database.

Expected output: 

1. Go into the Google Cloud Console > Cloud SQL and attempt to edit the dev database. 


## With resource export 

```
config-connector export "//sqladmin.googleapis.com/sql/v1beta4/projects/krm-test-5/instances/cymbal-dev" --output cymbalbank-policy/clusters/cymbal-admin/

config-connector export "//sqladmin.googleapis.com/sql/v1beta4/projects/krm-test-5/instances/cymbal-dev/databases/accounts-db" --output cymbalbank-policy/clusters/cymbal-admin/

config-connector export "//sqladmin.googleapis.com/sql/v1beta4/projects/krm-test-5/instances/cymbal-dev/databases/ledger-db" --output cymbalbank-policy/clusters/cymbal-admin/
```

## Part B - Enforcing Cloud Resources with Policy Controller 

One key benefit of bringing our - beyond continuous reconciliation - 

Region restriction for new databases 

https://cloud.google.com/architecture/policy-compliant-resources 



## Learn More 

- [Config Connector overview](https://cloud.google.com/config-connector/docs/overview)
- [List of Google Cloud resources supported by Config Connector](https://cloud.google.com/config-connector/docs/reference/overview)
- [`gcloud resource-config bulk-export](https://cloud.google.com/sdk/gcloud/reference/alpha/resource-config/bulk-export)