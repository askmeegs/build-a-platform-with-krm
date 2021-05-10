
## Part E - Main CI 

![screenshot](screenshots/main-ci.png)


####  1. **View the Cloud Build pipeline for commits to the `main` branch of the app source repo** 

```
cat ../cloudbuild-ci-main.yaml 
```

This pipeline runs when a pull request merges into the `main` branch. It does 4 things: 
1. Builds production images based on the source code that has just landed to the `main branch`. Those images are pushed to Google Container Registry in your project.
2. Clones the `cymbalbank-app-config` repo. 
3. Injects the new image tags into the deployment manifests in `cymbalbank-app-config`. 
4. Pushes those changes to the `main` branch of `cymbalbank-app-config`.  

Note that `cymbalbank-app-config` commits to the `main` branch trigger the Continuous Deployment pipeline we used in [Part 2](/2-how-krm-works). While we ran the Cloud Build trigger manually that time - using upstream release images rather than CI-generated images - this workflow will trigger it automatically. We'll see this in a few steps. 

#### 2. **Copy the main CI pipeline into cymbalbank-app-source.** 

```
cp ../cloudbuild-ci-main.yaml .
git add .
git commit -m "Add cloudbuild CI main" 
git push origin frontend-banner
```

#### 3. **Create a CI main Cloud Build trigger**

Reopen Cloud Build in the Google Cloud Console. Click Triggers > **Create Trigger**. 

- Name: `continuous-integration-main` 
- Event: `Push to a branch` 
- Repository: `<github-username>/cymbalbank-app-source` 
- Branch: `^main$`
- Configuration: Cloud Build configuration - `/cloudbuild-ci-main.yaml` 
- Click **Create**. 


#### **4. Merge the frontend-banner pull request**.

Do this by navigating back to Github and clicking "Squash and Merge." 

#### 5. **Watch the Continuous Integration - Main pipeline run in Cloud Build.**


#### 6. **When the build completes, navigate to Github and open the cymbalbank-app-config repo.** 

In the `base/` directory, and in each Deployment, you should see a new `image` tag, indicating that the CI pipeline injected the tag of the images built from the latest commit to `main`, which since your PR merged, includes the frontend banner source code. If you compare the image tag with the latest commit SHA to the `main` branch of `cymbalbank-app-source`, they should match. 

![base-tag](screenshots/base-tag.png)

