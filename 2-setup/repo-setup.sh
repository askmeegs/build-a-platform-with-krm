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

cp build/cloudbuild-ci-pr.yaml cymbalbank-app-source/
cp build/cloudbuild-ci-main.yaml cymbalbank-app-source/
cp build/skaffold.yaml cymbalbank-app-source/

cd cymbalbank-app-source/ 
git checkout main
git add .
git commit -m "Initialize app source repo"
git push origin main 
cd ..

echo "☸ Setting up app config repo..."
git clone "https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config"
cd cymbalbank-app-config; mkdir manifests/; 
cp -r ../app-manifests/* manifests/ 
cp ../build/cloudbuild-cd-prod.yaml . 

git add .
git commit -m "Initialize app config repo, trigger prod deploy"
git push origin main
cd .. 

