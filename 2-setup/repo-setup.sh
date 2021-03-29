#!/bin/bash 

########### VARIABLES  ##################################
if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi

if [[ -z "$GITHUB_USERNAME" ]]; then
    echo "Must provide GITHUB_USERNAME in environment" 1>&2
    exit 1
fi
##########################################################

echo "🏦 Setting up app source repo..."
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-source"
git clone "https://github.com/GoogleCloudPlatform/bank-of-anthos"
cp -r bank-of-anthos/* cymbalbank-app-source/ 
rm -rf bank-of-anthos 
rm -rf cymbalbank-app-source/dev-kubernetes-manifests/* 
cp -r app-manifests/*  cymbalbank-app-source/dev-kubernetes-manifests/


1. **Set up your app config repo**. 

```
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
cd cymbalbank-app-config; mkdir manifests/; 
cp -r ../app-manifests/ manifests/ 
cp ../cloudbuild.yaml .
git add .; git commit -m "Initialize repo"; git push origin main;   
```

