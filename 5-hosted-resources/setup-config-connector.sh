#!/bin/sh
# https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall 

if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi

gcloud config set project $PROJECT_ID
export SERVICE_ACCOUNT_NAME="cymbal-admin-kcc"

kcc_project_setup() {
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
}

uninstall_config_sync() {
    CLUSTER_NAME=$1 
    CLUSTER_ZONE=$2
    echo "☸️ Uninstalling Config Sync and Policy Controller: $CLUSTER_NAME, zone: $CLUSTER_ZONE"
    gcloud alpha container hub config-management apply \
    --membership=$CLUSTER_NAME \
    --config=remove-cs-spec.yaml \
    --project=$PROJECT_ID
}

install_config_connector () {
    CLUSTER_NAME=$1 
    CLUSTER_ZONE=$2 
    echo "☸️ Installing Config Connector: $CLUSTER_NAME, zone: $CLUSTER_ZONE" 

    kubectx $CLUSTER_NAME

    kubectl apply -f configconnector.yaml
    kubectl annotate namespace default cnrm.cloud.google.com/project-id=$PROJECT_ID 
}


kcc_project_setup
uninstall_config_sync "cymbal-admin" "us-central1-f"
install_config_connector "cymbal-admin" "us-central1-f"

echo "✅ Finished installing Config Connector on the admin cluster."