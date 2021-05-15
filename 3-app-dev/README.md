# 3 - App Development with KRM   

Now that we've set up Continuous Deployment for the Cymbal Bank app, you might be asking yourself, how did the application code actually get into those production containers? What if the code gets updated? 

If you look inside the `cymbalbank-app-config/` manifests, and look at the `image` tags for any of the Deployments in the `prod/` overlay, you'll see that for Demo 2, pre-built sample images were initially provided for you:

```YAML
    spec: 
      containers:
      - name: contacts
        image: gcr.io/bank-of-anthos/contacts:v0.4.3
```

In this demo, we'll explore how an app developer can get a new Cymbal Bank feature from their editor into production. 


## What you'll learn  
- How to set up a Kubernetes development environment using VSCode and Google Cloud Code 
- How the `skaffold` tool works with container builders like Docker and Jib to auto-build source code, and deploy to Kubernetes
- How to integrate `skaffold` with the `kustomize` manifests we saw in part 2 
- How to stage pull requests in Kubernetes automatically
- How to set up a complete CI/CD pipeline, building on the Continuous Deployment workflow from part 2 

## Prerequisites 

1. Complete demo [parts 1](/1-setup) and [2](/2-how-krm-works). 

### **[Continue to part A - setup](partA-setup.md)**. 
