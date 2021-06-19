
# Part E - Merging Your Pull Request 

![screenshot](screenshots/main-ci.jpg)

In Part 2, we created a Continuous Deployment pipeline, triggered on commits to the `main` branch of `cymbalbank-app-config`. This pipeline builds the prod manifests using the kustomize `prod` overlay and deploys to the production GKE cluster.

In this section, we'll create a "bridge" CI/CD pipeline, so that when a Pull Request in the `cymbalbank-app-source` repo merges into `main`, that updated release source code is built and deployed to the production GKE cluster. In order for this to happen, we have to create unique image tags, corresponding to a `main` branch commit, and inject those image tags into the `cymbalbank-app-config` repo's `prod/` manifests. Let's see how to do that.  

### 1. **View the Cloud Build pipeline for commits to the `main` branch of the app source repo** 

```
cat ../cloudbuild-ci-main.yaml 
```

Expected output: 

```YAML
steps: 
- name: 'gcr.io/google-samples/intro-to-krm/skaffold-mvn:latest'
  id: Build production images 
  entrypoint: /bin/sh
  args:
  - '-c'
  - |
    skaffold build --profile prod --default-repo="gcr.io/${PROJECT_ID}/cymbal-bank/release" --tag ${SHORT_SHA}
- name: 'gcr.io/cloud-builders/gcloud'
  id: Image tags -> cymbalbank-app-config prod manifests 
  entrypoint: 'bash'
  args:
   - '-eEuo'
   - 'pipefail'
   - '-c'
   - |-
    git clone https://github.com/$$GITHUB_USERNAME/cymbalbank-app-config && \
    cd cymbalbank-app-config 
    
    git config user.email $$GITHUB_EMAIL
    git config user.name $$GITHUB_USERNAME 
    git remote set-url origin https://$$GITHUB_USERNAME:$$GITHUB_TOKEN@github.com/$$GITHUB_USERNAME/cymbalbank-app-config.git

    for f in overlays/prod/*; do 
        if [[ "$f" == 'overlays/prod/kustomization.yaml' ]]; then
          continue
        fi
        svc="`basename $f .yaml`"
        echo "🏦 Service name: $svc"
        subst="image: gcr.io/${PROJECT_ID}/cymbal-bank/release/$svc:${SHORT_SHA}"

        echo "🐳 Injecting image tag: $subst > $f"  
        sed -i "s|image: $svc|$subst|g" $f 
        
        echo "📝 Done injecting image tag - $f"
        cat $f | grep "image: "
    done 

    git add . && \
    git commit -m "Updated image tag: ${SHORT_SHA}
    Built from commit ${COMMIT_SHA} of repository cymbalbank-app-source - main branch 
    Author: $(git log --format='%an <%ae>' -n 1 HEAD)" && \
    git push origin main
  secretEnv: ['GITHUB_EMAIL', 'GITHUB_USERNAME', 'GITHUB_TOKEN']
availableSecrets:
  secretManager:
  - versionName: projects/${PROJECT_ID}/secrets/github-username/versions/1 
    env: 'GITHUB_USERNAME'
  - versionName: projects/${PROJECT_ID}/secrets/github-token/versions/1 
    env: 'GITHUB_TOKEN'
  - versionName: projects/${PROJECT_ID}/secrets/github-email/versions/1 
    env: 'GITHUB_EMAIL'
timeout: '1200s' #timeout - 20 minutes
```

This pipeline will run when a pull request merges into the `main` branch. It does 4 things: 

1. Builds production images based on the source code that has just landed to the `main` branch. Those images are pushed to Google Container Registry in your project. Those images are tagged with the latest Git commit SHA to the `main` branch.
2. Clones the `cymbalbank-app-config` repo (remember, we're running out of the `cymbalbank-app-source` repo, just like the CI Pull Request pipeline we set up in Part D). 
3. Injects the new image tags (the ones we just built, with the Git commit SHA) into the deployment manifests in `cymbalbank-app-config`. 
4. Pushes those YAML file changes to the `main` branch of `cymbalbank-app-config`, authenticated with your `GITHUB_TOKEN` stored in Secret Manager.  

### 2. **Copy the main CI pipeline into cymbalbank-app-source.** 

```
cp ../cloudbuild-ci-main.yaml .
git add .
git commit -m "Add cloudbuild CI main" 
git push origin frontend-banner
```

### 3. **Create a CI main Cloud Build trigger**

Reopen Cloud Build in the Google Cloud Console. Click Triggers > **Create Trigger**. 

- Name: `continuous-integration-main` 
- Event: `Push to a branch` 
- Repository: `<github-username>/cymbalbank-app-source` 
- Branch: `^main$`
- Configuration: Cloud Build configuration - `/cloudbuild-ci-main.yaml` 
- Click **Create**. 


### 4. **Wait for the frontend-banner branch's PR CI to build, then merge the pull request**.

When the Pull Request's Cloud Build pipeline is complete, you should see a check-mark in Github next to the latest commit to the `frontend-banner` branch. If you mouse over the check-mark, you should see a window like the one below. **Note** - it may take 5-10 minutes for your pipeline to complete. 

![](screenshots/pr-ready-to-merge.png)

Now, merge the Pull Request by clicking **Squash and Merge.** 

### 5. **Watch the Continuous Integration - Main pipeline run in Cloud Build.** Wait for the build to complete. 

![ci-main-success](screenshots/ci-main-success.png)

### 6. **When the build completes, navigate to [Google Container Registry](https://console.cloud.google.com/gcr) in the Cloud Console.** 

From the Container Registry dashboard, navigate into the `cymbal-bank` folder, then the `release` subfolder. You should see the list of Cymbal Bank services, which the Continuous Integration pipeline just pushed.

![gcr](screenshots/gcr.png)

### 7. **Navigate back to Github and open the cymbalbank-app-config repo.** 

In the `overlays/prod/` directory, and in each Deployment, you should see a new `image` tag, indicating that the CI pipeline injected the tag of the images built from the latest commit to `main`, which since your PR merged, includes the frontend banner source code. 

![](screenshots/injected-tag.png)

When this CI pipeline finished, injecting the new image tags in the manifests and committing to the `main` branch, we actually triggered the Continuous Deployment pipeline to run.  Let's see that in action - **[Continue to Part F](partF-cd.md)** to finish up this demo.
