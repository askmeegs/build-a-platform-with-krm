## Part A - Setup  

#### 1. `cd` into this directory. 

```
cd 2-how-krm-works/
```

#### 2. **Set variables.**

```
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```


#### 3. **Clone the app config repo.** 

This Github repo should have been created in your account during setup. This repo will contain the Kubernetes manifests (KRM) for the CymbalBank application. 

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
```

Expected output: 

```
Cloning into 'cymbalbank-app-config'...
warning: You appear to have cloned an empty repository.
```

**[Continue to part B - Introducing KRM](partB-introducing-krm.md)**
