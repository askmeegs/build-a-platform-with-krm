
## Part C - Managing Existing Cloud Resources with Config Connector 

Up to now, we've used Config Connector to generate *new* hosted resources, in both Compute Engine and BigQuery. But if you remember way back in part 1, we used Terraform to initially bootstrap the demo environment. This included creating multiple GKE clusters, a set of Secret Manager secrets, some IAM resources, and multiple Cloud SQL instances for dev, staging, and prod. 

For this final demo of the series, let's learn how to bring existing Google Cloud resources into the management of Config Connector, via gcloud and Config Sync. 

1. [Install the Config Connector tool](https://cloud.google.com/config-connector/docs/how-to/import-export/overview#installing-config-connector) and ensure it's in your PATH: 

```
config connector version
```

Expected output: 

```
1.46.0
```

1. Run the Cloud SQL KRM export script. (Note - gcloud bulk export command is an alternative)

1. Commit to the policy repo. 

1. Wait for the resources to sync. 

1. Get the Config Connector resource status on the cymbal-admin cluster. 

```
kubectl get gcp
```

Expected output: 

```
NAME                                                AGE   READY   STATUS     STATUS AGE
sqldatabase.sql.cnrm.cloud.google.com/accounts-db   27s   True    UpToDate   24s
sqldatabase.sql.cnrm.cloud.google.com/ledger-db     27s   True    UpToDate   24s

NAME                                               AGE   READY   STATUS     STATUS AGE
sqlinstance.sql.cnrm.cloud.google.com/cymbal-dev   42s   True    UpToDate   10s
```

1. Open the Cloud Console and navigate to Cloud SQL. Notice how in the list, the `cymbal-dev` cluster now has a new label, `managed-by-cnrm: true`. This indicates that this SQL Instance is now under the management umbrella of Config Connector. 


1. Click Edit and add a label, `hello:world`, then click save. 

1. Watch the status of the KRM resource for the cymbal-dev SQL instance, and wait for an attempted reconcile - this may take a few minutes. 

1. Should see the hello world label go away, indicating that any manual updates will always be reverted by the source of truth for that sql instance - synced via Config Sync and actuated via Config Connector. 

Nice job! You just learned how to export existing, live cloud-hosted resources as declarative KRM. 

## Learn More 

- [Config Connector overview](https://cloud.google.com/config-connector/docs/overview)
- [List of Google Cloud resources supported by Config Connector](https://cloud.google.com/config-connector/docs/reference/overview)
- [Github - Config Connector samples](https://github.com/GoogleCloudPlatform/k8s-config-connector/tree/master/samples/resources)
- [`gcloud resource-config bulk-export](https://cloud.google.com/sdk/gcloud/reference/alpha/resource-config/bulk-export)
- [Google Cloud Blog - "Sign here! Creating a policy contract with Configuration as Data" - Kelsey Hightower and Mark Balch](https://cloud.google.com/blog/products/containers-kubernetes/how-configuration-as-data-impacts-policy)
- [Github - Config Connector + Policy Controller demo - Kelsey Hightower](https://github.com/kelseyhightower/config-connector-policy-demo) 
- [Google Cloud Architecture Center - Creating Policy-Compliant Cloud Resources](https://cloud.google.com/architecture/policy-compliant-resources)
- [Config Connector docs - Importing and exporting existing Google Cloud resources](https://cloud.google.com/config-connector/docs/how-to/import-export/export)

## Wrap-up 

If you made it this far, great work - you just completed several challenging demos that explored the Kubernetes Resource Model with multiple angles, developer personas, products, and tools. 

Let's summarize the key takeaways from all 5 demos: 

- Building a platform is hard, especially in the cloud, especially when you have multiple Kubernetes clusters in play on top of hosted resources.  
- KRM is one way to manage your Cloud and Kubernetes config in one place, but it's not the only way - Demo 1 showed us how to do it with Terraform. 
- KRM is a great way to manage resources because Kubernetes is constantly running a control loop to make sure your desired state matches the actual cluster state. We saw this in action both for core Kubernetes API resources (Demo 2 / for instance, Deployments that keep Pods alive) and hosted Cloud resources (Demo 5 / via Config Connector)
- KRM promotes a "GitOps" model where you keep all your configuration in Git. This allowed us to set up CI/CD both for the app itself (Demo 3 / deploying pods to staging), and for the policy configuration (Demo 4)
- Policy Controller, together with Config Sync, allow you to impose custom policies on your KRM resources, both at deploy-time and during CI/CD (Demo 4)

Hopefully you learned a thing or two from these demos- really, we've only just scratched the surface of what KRM can do. Here's a bunch of stuff these demos didn't cover, 

- Debugging Config Sync https://cloud.google.com/anthos-config-management/docs/how-to/monitoring#example_debugging_procedures 
- [Best practices for policy management with Anthos Config Management and GitLab](https://cloud.google.com/solutions/best-practices-for-policy-management-with-anthos-config-management)
- Hierarchy Controller 
- Policy Controller audits 
- [Reporting Policy Controller audit violations in Security Command Center](https://cloud.google.com/architecture/reporting-policy-controller-audit-violations-security-command-center)
- Pod security policies https://cloud.google.com/anthos-config-management/docs/how-to/using-constraints-to-enforce-pod-security 
- [kpt](https://cloud.google.com/architecture/managing-cloud-infrastructure-using-kpt) 

And for a set of resources to learn more about KRM, its design principles, and other helpful tools, see: https://github.com/askmeegs/learn-krm 