#!/bin/sh
# https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall 

if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi

gcloud config set project $PROJECT_ID
export SERVICE_ACCOUNT_NAME="cymbal-admin-kcc"

echo "☁️ Creating a Google Service Account (GSA) for Config Connector..."
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME

echo "☁️ Granting the GSA cloud resource management permissions..." 
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/owner"

echo "☁️ Connecting your Google Service Account to the Kubernetes Service Account (KSA) that Config Connector uses..."
gcloud iam service-accounts add-iam-policy-binding \
cymbal-admin-kcc@$PROJECT_ID.iam.gserviceaccount.com \
    --member="serviceAccount:$PROJECT_ID.svc.id.goog[cnrm-system/cnrm-controller-manager]" \
    --role="roles/iam.workloadIdentityUser"

# Populate configconnector.yaml
echo "☁️ Populating and deploying configconnector.yaml with your GSA info..."
sed -i "s/PROJECT_ID/$PROJECT_ID/g" configconnector.yaml


install_kcc () {
    CLUSTER_NAME=$1 
    CLUSTER_ZONE=$2 
    echo "☸️ Installing Config Connector: $CLUSTER_NAME, zone: $CLUSTER_ZONE" \

    kubectx $CLUSTER_NAME

    # Apply configconnector.yaml 
    echo "☁️ Installing the Config Connector controller..." 
    kubectl apply -f configconnector.yaml
    kubectl annotate namespace default cnrm.cloud.google.com/project-id=$PROJECT_ID 
}

# Note - due to an ongoing bug, Config Sync and Config Connector can't be installed 
# on GKE at the same time. So dev/staging/prod have Config Sync, and admin has config connector. 

# install_kcc "cymbal-dev" "us-east1-c" 
# install_kcc "cymbal-staging" "us-central1-a" 
# install_kcc "cymbal-prod" "us-west1-a"
install_kcc "cymbal-admin" "us-central1-f"

echo "✅ Finished installing Config Connector on the admin cluster."