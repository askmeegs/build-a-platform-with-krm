
## Part A - Setup  

#### 1. **Open a Terminal and set variables.**

```
cd 3-app-dev/
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```

#### 2. **Switch to the `cymbal-dev` kubecontext.**

```
kubectx cymbal-dev
```

#### 3. **Clone and initialize the app source repo**.

Do this by copying the upstream [Bank of Anthos](https://github.com/googlecloudplatform/bank-of-anthos) sample app source code into your app-source-repo. Then remove the upstream Bank of Anthos repo from your local environment.  

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-source"
cd cymbalbank-app-source 
touch README.md 
git add README.md
git commit -m "first commit"
git push origin main
git checkout -b frontend-banner
cd .. 
```

### 4. **Copy the CymbalBank source code into the app source repo.** 

```
git clone "https://github.com/GoogleCloudPlatform/bank-of-anthos"
cd bank-of-anthos; rm -rf .git; cd .. 
cp -r bank-of-anthos/ cymbalbank-app-source/ 
rm -rf bank-of-anthos 
```

#### 5. **Clone the app config repo inside the app source repo.**

The reason for doing this is so that `skaffold`, the tool that builds the Docker images, has the YAML files it needs to deploy to the dev GKE cluster. 

```
cd cymbalbank-app-source; 
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
```
