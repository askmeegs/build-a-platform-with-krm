# 3 - Kustomize 

This demo shows how app developers can use Kustomize, a KRM command-line tool, to build and test application features without writing any YAML. 

### Prerequisites 

- Completed the [Setup demo](/2-setup) - this created a Github repo, `cymbalbank-app-config`, in your Github account.
- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [skaffold](https://skaffold.dev/docs/install/)

### Setup 

1. Set variables. 

```
PROJECT_ID = <your-project-id>
ZONE = <your-zone>
REGION = <your-region>
GITHUB_USERNAME = <your-github-username>

PROJECT_ID="krm-awareness"
ZONE="us-east1-b"
REGION="us-east1" 
GITHUB_USERNAME="askmeegs"

```

2. Create a development cluster. This will take a few minutes.

```
gcloud container clusters create cymbalbank-dev \
--project=${PROJECT_ID} --zone=${ZONE} \
--machine-type=e2-standard-4 --num-nodes=4 \
--workload-pool="${PROJECT_ID}.svc.id.goog"
```

3. Make sure you're in the root of this repository `intro-to-krm/`, then clone the CymbalBank source code. 

```
git clone https://github.com/googlecloudplatform/bank-of-anthos
```

Note: your app config rep, `cymbalbank-app-config`, should already be cloned to the `intro-to-krm/` root directory, from the Setup demo before. If it's not, clone it. 

```
git clone https://github.com/${GITHUB_USERNAME}/cymbalbank-app-config
```

4. Create the Cloud SQL test database, and populate with test data. This script takes 5-10 minutes to complete. 

```
./3-kustomize/setup-cloudsql.sh
```


### Using Kustomize for KRM Hydration 


### Using skaffold for continuous development 