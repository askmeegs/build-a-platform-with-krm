
## Part A - Introducing Config Connector for Kubernetes

Way back in Part 1, we used Terraform to set up a bunch of cloud resources - this included multiple GKE clusters, IAM resources, Cloud SQL databases, and Secret Manager secrets. 

Why KRM for cloud resources? 
- Frees you from gcloud / bash scripts 
- Unify K8s and non K8s resources into 1 repo, 1 format 
- GitOps + config sync for hosted resources ( > TF)
- Policy checks for hosted resources 


Config Connector can be installed to GKE as a cluster add-on, on cluster creation, so config sync is already running on the Cymbal Admin cluster. You may have also noticed we didn't install Config Connector on any of the other clusters -- because Config Connector spawns Google Cloud resources outside the cluster, we want to avoid multiple copies of the same resource deployed into different clusters, to avoid clobbering. 

1. Run the setup script 

```
./setup-config-connector.sh 
```

Let's start with a basic example of creating a GCP-hosted resource using Config Connector, declared with KRM. Let's say that one of the security admins in CymbalBank only has access to a Windows machine, and they want to start working with the platform team to study and create org-wide policies using the Policy Controller constraints we learned about in part 4. Because some of the tools we've learned don't support Windows yet, we can spin up a Linux host for them so they have access to a full development environment. 

![screenshot](screenshots/secadmin-gce.jpg)

1. **Set variables.** 

```
export PROJECT_ID=your-project-id
export GITHUB_USERNAME=your-github-username 
```

2. **Clone the `cymbalbank-policy` repo into this directory.** 

```
git clone https://github.com/$GITHUB_USERNAME/cymbalbank-policy 
```

3. **Create a `clusters/cymbal-admin` directory in the `cymbalbank-policy` repo.** 

```
mkdir -p cymbalbank-policy/clusters/cymbal-admin 
```

4. **View the GCE KRM resources.** 

```
cat gce-secadmin/instance.yaml 
```

5. **Copy the GCE resources into the `cymbal-admin` directory.** 


```
cp gce-secadmin/instance.yaml cymbalbank-policy/clusters/cymbal-admin 
```

6. **Commit the resources to the cymbalbank-policy repo.** 

```
cd cymbalbank-policy
git add .
git commit -m "Add GCE instance - Config Connector" 
git push origin main 
```

7. **Wait for the cymbal-admin cluster to sync.** 

```
gcloud alpha container hub config-management status --project=${PROJECT_ID}
```

8. **Get the status of the deployed resources.** 

```
kubectl get gcp 
```

Expected output: 

```
NAME                                                                               AGE     READY   STATUS     STATUS AGE
computesubnetwork.compute.cnrm.cloud.google.com/computeinstance-dep-cloudmachine   5m57s   True    UpToDate   5m3s

NAME                                                            AGE    READY   STATUS     STATUS AGE
computeinstance.compute.cnrm.cloud.google.com/secadmin-debian   6m1s   True    UpToDate   4m3s

NAME                                                                            AGE     READY   STATUS     STATUS AGE
computenetwork.compute.cnrm.cloud.google.com/computeinstance-dep-cloudmachine   5m59s   True    UpToDate   5m48s

NAME                                                                          AGE   READY   STATUS     STATUS AGE
computedisk.compute.cnrm.cloud.google.com/computeinstance-dep1-cloudmachine   6m    True    UpToDate   5m44s
computedisk.compute.cnrm.cloud.google.com/computeinstance-dep2-cloudmachine   6m    True    UpToDate   5m48s

NAME                                                                AGE     READY   STATUS     STATUS AGE
iamserviceaccount.iam.cnrm.cloud.google.com/inst-dep-cloudmachine   5m58s   True    UpToDate   5m57s
```

9. **In a browser, open the Cloud Console and navigate to Compute Engine > VM Instances. Filter on `name:secadmin`. You should see the new GCE instance in the list.** 

![screenshots](screenshots/secadmin-gce-console.png)

**🌈 Nice job!** You just deployed your first cloud-hosted resource with KRM! 

You'll notice that we (the platform admin) had to manually create the GCE resources, and push to the config repo. In a real-life scenario, the platform team might even set up a self-service system with a basic web UI, so that Cymbal Bank employees can request a GCE instance. This web app would take in parameters (like choose an operating system from a drop-down menu, disk size, etc.), and generate a JSON or YAML file with the GCE KRM, commit it to the repo automatically. This would provide a hands-off way of allowing users to set up their own resources, while maintaining a centralized, auditable source of truth in Git. 
