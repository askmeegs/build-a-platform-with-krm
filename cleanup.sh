#!/bin/bash 

if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi

if [[ -z "$GITHUB_USERNAME" ]]; then
    echo "Must provide GITHUB_USERNAME in environment" 1>&2
    exit 1
fi

gcloud config set project $PROJECT_ID 

echo "🗑 Deleting Cloud Storage bucket for BigQuery..."
gsutil rb -f gs://$PROJECT_ID-datasets

echo "🗑 Deleting Config Connector-managed resources (Compute Engine, BigQuery, Cloud SQL)..."
kubectx cymbal-admin 
kubectl delete -f 5-hosted-resources/bigquery/mock-dataset.yaml 
kubectl delete -f 5-hosted-resources/compute-engine/instance.yaml
kubectl delete -f cloudsql/projects/$PROJECT_ID/SQLInstance/us-east1/cymbal-dev.yaml
kubectl delete -f cloudsql/projects/$PROJECT_ID/SQLInstance/cymbal-dev/SQLDatabase/accounts-db.yaml
kubectl delete -f cloudsql/projects/$PROJECT_ID/SQLInstance/cymbal-dev/SQLDatabase/ledger-db.yaml

echo "💤 Sleeping 30 seconds to allow Config Connector to delete Cloud Resources..."
sleep 30 

# Deregister Anthos clusters 
echo "🗑 De-registering Anthos clusters..."
gcloud container hub memberships delete cymbal-dev --async --quiet 
gcloud container hub memberships delete cymbal-staging --async --quiet 
gcloud container hub memberships delete cymbal-prod  --async --quiet 
gcloud container hub memberships delete cymbal-admin  --async --quiet 

echo "🗑 Deleting CymbalBank service account ..."
gcloud iam service-accounts delete cymbal-gsa@$PROJECT_ID.iam.gserviceaccount.com --quiet 

# Terraform destroy (GKE clusters, Git repos, Cloud Build permissions, Cloud SQL databases)
echo "🗑 Running terraform destroy to remove GKE clusters, Cloud SQL databases..." 
cd 1-setup/
terraform destroy

# Prompt user to delete github repos on their own 
# echo "✅ Google Cloud resources deleted. To delete your Github repos, navigate to the following URLs, click Settings > Delete Repository."

# echo "https://github.com/$GITHUB_USERNAME/cymbalbank-app-source"
# echo "https://github.com/$GITHUB_USERNAME/cymbalbank-app-config"
# echo "https://github.com/$GITHUB_USERNAME/cymbalbank-policy"