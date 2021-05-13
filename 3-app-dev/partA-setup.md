
## Part A - Setup  

1. **Open a Terminal and set variables.**

```
cd 3-app-dev/
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```

2. **Switch to the `cymbal-dev` kubecontext.**

```
kubectx cymbal-dev
```

Expected output: 

```
Switched to context "cymbal-dev".
```

3. **Clone and initialize the app source repo** in the `app-dev/` directory.

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

4. **Populate the `cymbalbank-app-source` repo with the upstream [Bank of Anthos](https://github.com/googlecloudplatform/bank-of-anthos) sample app code.**

```
git clone "https://github.com/GoogleCloudPlatform/bank-of-anthos"
cd bank-of-anthos; rm -rf .git; cd .. 
cp -r bank-of-anthos/ cymbalbank-app-source/ 
rm -rf bank-of-anthos 
```

5. **Clone the `cymbalbank-app-config` repo inside the `cymbalbank-app-source` repo.**

```
cd cymbalbank-app-source; 
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
```

Expected output: 

```
Receiving objects: 100% (37/37), 16.46 KiB | 411.00 KiB/s, done.
Resolving deltas: 100% (25/25), done.
```

Let's walk through why we're doing this: the `cymbalbank-app-source` directory contains no Kubernetes YAML on its own, just the Python and Java source code of the app itself. The Kubernetes manifests for the app - or, the kustomize `base/` and `overlays/` we saw in part 2 - live in a separate repo, allowing for a decoupling between source code and YAML. It's not a hard requirement to separate these, but it will allow us to do more fine-grained CI/CD later in this demo.

So the reason we clone `cymbalbank-app-config` inside `cymbalbank-app-source` is so that we have YAML files available to us - including the `dev/` overlay - to test new application features in a developmpent cluster. 