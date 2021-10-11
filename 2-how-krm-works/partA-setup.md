# Part A - Setup  

### 1. **`cd` into this directory from the root of this repository.**

```
cd 2-how-krm-works/
```

### 2. **Set variables.**

```
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```

### 3. **Clone the cymbalbank-app-config repo.** 

This Github repo should have been created in your account during setup. This repo will contain the Kubernetes manifests (KRM) for the CymbalBank application. 

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
```

**Note** - Following parts of this tutorial assume that your default branch name is `main` instead of `master`. You can configure it on your local machine running `git config --global init.defaultBranch main`

Expected output: 

```
Cloning into 'cymbalbank-app-config'...
warning: You appear to have cloned an empty repository.
```

### **[Continue to part B - Introducing KRM](partB-introducing-krm.md)**.
