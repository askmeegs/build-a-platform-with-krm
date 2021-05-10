
## Part D - Creating a Continuous Deployment Pipeline

![demo arch](screenshots/basic-deploy.png)

[**GitOps**](https://www.weave.works/technologies/gitops/) is an idea introduced by [WeaveWorks](https://www.weave.works/). It's an operating model for Kubernetes where you put your Kubernetes configuration in Git, then allow software - like CI/CD tools - to deploy. In this way, the only human interactions with the system are pull requests to the Github repo - these can be reviewed, approved, and audited - rather than imperative commands like `kubectl apply -f`, which are difficult to keep track of and may result in unwanted KRM landing in Kubernetes. The other benefit of GitOps is that there is one "source of truth" for what the desired Kubernetes state should be. 

Let's implement a simple, GitOps-style continuous deployment pipeline for CymbalBank using Google Cloud Build. 

#### 1. **View the continuous deployment pipeline**. 
  
This YAML file defines a Google Cloud Build pipeline that runs the `kubectl apply -k` command described above, effectively deploying the demo overlay in the `cymbalbank-app-config` repo to the `cymbal-prod` cluster. 

```
cat cymbalbank-app-config/cloudbuild-cd-prod.yaml 
```

Expected output: 

```
steps:
- name: 'gcr.io/cloud-builders/kubectl'
  id: Deploy
  args:
  - 'apply'
  - '-k'
  - 'overlays/prod/'
  env:
  - 'CLOUDSDK_COMPUTE_ZONE=us-west1-a'
  - 'CLOUDSDK_CONTAINER_CLUSTER=cymbal-prod'
```

(Note that in a real production environment, you'd likely want to set up a progressive deployment into prod, using something like a [Rolling Update](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/) or a [Canary Deployment](https://www.istiobyexample.dev/canary), to safeguard against downtime or potential outages.)

#### 2. **Set up Cloud Build authentication to Github**. 

This allows Cloud Build to watch the Github repositories in your account.  

- [Open Cloud Build](https://console.cloud.google.com/cloud-build) in the Google Cloud Console. 
- Ensure that in the top menubar drop-down, your demo project is correctly selected. 
- On the left sidebar, click **Triggers.**  
- Click **Connect Repository.** 
- In the menu that pops up on the right, for `Select Source`, choose Github. Authenticate to your Github account, then under repositories, search `cymbal`. 
- Check **all 3 cymbal-bank repositories** -- `cymbalbank-app-source`, `cymbalbank-app-config`, and `cymbalbank-policy`. We'll create Cloud Build triggers for all 3 repos over the course of the demos. 
- Click **Connect.** 
- Click **Done**. 

#### 3. **Create a Cloud Build trigger for cymbalbank-app-config**. 

- In the Triggers menu, click **Create Trigger.** 
- Name it `continuous-deployment-prod`
- Under **Event**, choose `Push to a branch`
- Under **Source**, choose the `cymbalbank-app-config` repo. Enter `main` next to **Branch**. This means that the build will run with every push the `main` branch of this repo. 
- Under **Configuration**, click `Cloud Build configuration file`, `Repository`, and enter `cloudbuild-cd-prod.yaml` next to file location. 
- Click **Create.** 

You should now see the trigger appear in the Cloud Build menu. 

![trigger](screenshots/trigger.png)


#### 4. **Trigger the build by pushing the manifests to your config repo.** 

```
cd cymbalbank-app-config/
git add .
git commit -m "Initialize app config repo"
git push origin main
cd .. 
```

#### 5. **Navigate back to Cloud Build and in the left sidebar, click History.** 

Watch the Cloud Build logs as the Continuous Deployment pipeline runs, using `kubectl apply -k` to apply the demo overlay and deploy to the `cymbal-prod` cluster: 


![cd success](screenshots/cd-success.png)


#### 6. Return to a terminal and get the pods in the `cymbal-prod` cluster: 

```
kubectx cymbal-prod; kubectl get pods --all-namespaces --selector=org=cymbal-bank
```

Expected output: 

```
NAMESPACE            NAME                                  READY   STATUS    RESTARTS   AGE
balancereader        balancereader-7bd58bcd4f-q9kpj        2/2     Running   1          5m53s
contacts             contacts-7694bb5cb6-2tl8r             2/2     Running   0          5m53s
frontend             frontend-78dcb46b5c-9bmz4             1/1     Running   0          5m53s
frontend             frontend-78dcb46b5c-l84j9             1/1     Running   0          5m53s
frontend             frontend-78dcb46b5c-vv6sd             1/1     Running   0          5m53s
ledgerwriter         ledgerwriter-7959866b4f-5qbjr         2/2     Running   0          5m53s
loadgenerator        loadgenerator-6d66d47f98-fltss        1/1     Running   0          5m52s
transactionhistory   transactionhistory-6c5f59b66c-n4cbf   2/2     Running   0          5m52s
userservice          userservice-5b4b8c8c59-hgnqs          2/2     Running   0          5m52s
```

Notice how there are 3 frontend `replicas`, as defined in the `prod` kustomize overlay. 

You can also run `kubectl get` on the other resource types just deployed, including Services: 

```
kubectl get services  --all-namespaces --selector=org=cymbal-bank
```

Expected output: 

```
NAMESPACE            NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
balancereader        balancereader        ClusterIP      10.7.252.14    <none>        8080/TCP       3m44s
contacts             contacts             ClusterIP      10.7.241.192   <none>        8080/TCP       3m44s
frontend             frontend             LoadBalancer   10.7.241.130   36.101.109.3  80:31541/TCP   3m44s
ledgerwriter         ledgerwriter         ClusterIP      10.7.244.168   <none>        8080/TCP       3m44s
transactionhistory   transactionhistory   ClusterIP      10.7.249.66    <none>        8080/TCP       3m43s
userservice          userservice          ClusterIP      10.7.249.254   <none>        8080/TCP       3m43s
```

Notice how each service uses `ClusterIP` (enable in-cluster routing only) except for the `frontend`, which is of type `LoadBalancer`. This type means that GCP spawned an external load balancer to route from outside the cluster, into the frontend pod. Navigate to your frontend service `EXTERNAL_IP` in a browser - you should see the CymbalBank login screen. 

![screenshot](screenshots/cymbal-login.png)

### Clean Up 

1. To prepare for the next demo, update `cloudbuild-cd-prod` and replace `overlays/demo` in line 7 with: 

```
  - 'overlays/prod/'
```

This will prepare you to deploy images from source code, rather than pre-baked demo images.

2. Push to the main branch. 

```
git add .
git commit -m "CD pipeline - use prod overlay
git push origin main 
```

Note that if you check back into your `cymbal-prod` cluster and get pods, you'll see `ImagePullBackOff` errors - this is expected and we'll resolve this in Part 3 when we build some new images! 

🥳 **Well done! You just learned how KRM works, and how to deploy Kubernetes resources to a cluster using GitOps best practices.**


## Learn More 

- [Kubernetes docs - working with Kubernetes objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
- [Github - Kubernetes - the Kubernetes Resource Model](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/resource-management.md)
- [Github - jamiehannaford - what-happens-when-k8s](https://github.com/jamiehannaford/what-happens-when-k8s)
- [Google Cloud - GKE Cluster Architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture#control_plane)
- [Kubernetes Docs - Architecture - Controllers](https://kubernetes.io/docs/concepts/architecture/controller/)
- [Kustomize docs - Introduction](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [WeaveWorks Guide to GitOps](https://www.weave.works/technologies/gitops/)
- [Google Cloud Build - Deploying to GKE](https://cloud.google.com/build/docs/deploying-builds/deploy-gke)
