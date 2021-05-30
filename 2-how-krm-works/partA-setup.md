# Part A - Setup  

### 1. **`cd` into this directory.**

```bash
cd 2-how-krm-works/
```

### 2. **Set variables.**

```bash
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```

### 3. **Clone the cymbalbank-app-config repo.** 

This Github repo should have been created in your account during setup. This repo will contain the Kubernetes manifests (KRM) for the CymbalBank application. 

```bash
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
```

Expected output: 

```bash
Cloning into 'cymbalbank-app-config'...
warning: You appear to have cloned an empty repository.
```

### **[Continue to part B - Introducing KRM](partB-introducing-krm.md)**.
