#!/bin/bash
# https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall 

if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi

kubectx cymbal-admin 

echo "☁️ Creating a Google Service Account (GSA) for Config Connector..."
gcloud iam service-accounts create cymbal-admin-kcc

echo "☁️ Granting the GSA cloud resource management permissions..." 
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:cymbal-admin-kcc@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/owner"

echo "☁️ Connecting your Google Service Account to the Kubernetes Service Account (KSA) that Config Connector uses..."
gcloud iam service-accounts add-iam-policy-binding \
cymbal-admin-kcc@$PROJECT_ID.iam.gserviceaccount.com \
    --member="serviceAccount:$PROJECT_ID.svc.id.goog[cnrm-system/cnrm-controller-manager]" \
    --role="roles/iam.workloadIdentityUser"

# Populate configconnector.yaml
echo "☁️ Populating and deploying configconnector.yaml with your GSA info..."
sed -i "s/PROJECT_ID/$PROJECT_ID/g" configconnector.yaml 

# Apply configconnector.yaml 
kubectl apply -f configconnector.yaml

echo "☁️ Creating config-connector Kubernetes namespace for GCP KRM resources..."
kubectl create namespace config-connector

echo "☁️ Telling Config Connector which project to deploy resources into..."
kubectl annotate namespace config-connector cnrm.cloud.google.com/project-id=$PROJECT_ID 

echo "✅ Finished setting up Config Connector on cymbal-admin."