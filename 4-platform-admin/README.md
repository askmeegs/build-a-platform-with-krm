# 4 - Administering KRM with Config Sync and Policy Controller

⏱ *estimated time: 3 hours* 

In [part 2](/2-how-krm-works), we learned how the Kubernetes API works, and how to apply resources with `kubectl apply -f`. Then in [part 3](/3-app-dev), we learned how to automatically deploy KRM using skaffold and Cloud Build, with the help of kustomize. 

These two use cases cover Kubernetes app development pretty well. But now imagine that you're a platform developer or administrator, responsible for not just one of the CymbalBank services, but for the entire Kubernetes environment, including the `dev`, `staging`, and `prod` clusters. An app developer may care most about testing their code and getting features into production with minimal friction, but your concerns are probably different. You care about consistency across the whole platform - that certain baseline resources are always deployed and in sync across all the clusters. (You do *not* want a developer to `kubectl apply -f` one of those resources by mistake, and you especially don't want that to happen without anyone knowing.) You also care about compliance with the financial services regulations CymbalBank is subject to, and you might work directly with Cymbal's security team to make sure the necessary policies are in place. 

So if I'm a platform admin, I really care about two things with KRM: 1) **Consistency**, and 2) **Protect the clusters from unsafe configuration**. This demo explores how two Google Cloud tools - **Config Sync** and **Policy Controller** - help platform admins accomplish those two goals. 

## What you'll learn 

- How GitOps promotes security best practices
- How to use Config Sync to sync KRM from Github to multiple GKE clusters
- When to deploy KRM using Config Sync, and when to deploy KRM using CI/CD 
- How to scope KRM resources to only apply to certain GKE clusters
- How Policy Controller promotes compliance in a Kubernetes environment
- How to use Policy Controller to define org-wide policies, synced with ConfigSync.
- How to write your own Policy Controller policies to enforce custom logic
- How to integrate Policy Controller checks into CI/CD to add an extra layer of enforcement 

## Prerequisites 

- Complete parts 1-3. 

### **[Continue to Part A - Installing Config Sync and Policy Controller.](partA-installation.md)**