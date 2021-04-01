# 3 - App Development with KRM   

This demo shows an example App Developer workflow in a KRM environment, using the `skaffold` and `kustomize` tools to build app features without writing any new YAML files. 

In this scenario, Alice is an app developer

### Prerequisites 

Complete demo [parts 1](/1-setup) and [2](/2-how-krm-works). 

```

git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-source"
git clone "https://github.com/GoogleCloudPlatform/bank-of-anthos"
cp -r bank-of-anthos/* cymbalbank-app-source/ 
rm -rf bank-of-anthos 

cp build/cloudbuild-ci-pr.yaml cymbalbank-app-source/
cp build/cloudbuild-ci-main.yaml cymbalbank-app-source/
cp build/skaffold.yaml cymbalbank-app-source/

cd cymbalbank-app-source/ 
git checkout main
git add .
git commit -m "Initialize app source repo"
git push origin main 
cd ..

```


### Steps 

1. Set vars. 

```
export PROJECT_ID=<your-project-id>
export GITHUB_USERNAME=<your-github-username>
```

1. Clone and initialize the app source repo. 


1. Clone the app config repo inside the app source repo, as a Git submodule. The reason for doing this is so that `skaffold`, the tool that builds the Docker images, needs YAML files. Note that the app developer won't commit directly to the app config repo - this is only writeable from the automated CI. 


1. Check out a new local branch, and update the frontend source code. For instance, let's add a banner to the login page advertising a new interest rate on all checking accounts. 




1. Push the code to the new branch, and put out a pull request in the app source repo. 


1. Merge the PR. 
