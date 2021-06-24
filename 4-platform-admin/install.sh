#!/bin/bash 

# Installs Config Sync and Policy Controller on the dev, staging, and prod clusters. 

########### VARIABLES  ##################################
if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi

if [[ -z "$GITHUB_USERNAME" ]]; then
    echo "Must provide GITHUB_USERNAME in environment" 1>&2
    exit 1
fi


install_config_sync () {
    CLUSTER_NAME=$1 
    CLUSTER_ZONE=$2 
    echo "********** Installing Config Sync + Policy Controller: $CLUSTER_NAME, zone: $CLUSTER_ZONE ***************" 

    kubectx $CLUSTER_NAME 
    # kubectl apply -f config-management-operator.yaml
    # # inject github username into Config Management YAML + apply 
    # CRD_FILE="config-management-crds/${CLUSTER_NAME}.yaml"
    # gsed -i "s/GITHUB_USERNAME/${GITHUB_USERNAME}/g" $CRD_FILE

    # install config sync by applying the CRD 
    # kubectl apply -f config-management-crds/${CLUSTER_NAME}.yaml
    gcloud alpha container hub config-management apply \
    --membership=$CLUSTER_NAME \
    --config=apply-spec.yaml \
    --project=$PROJECT_ID
}

# Enable config management feature in Anthos 
gcloud config set project $PROJECT_ID
gcloud alpha container hub config-management enable

# Download Config Sync operator 
# gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml


# Install Config Sync on dev, staging, and prod 
install_config_sync "cymbal-dev" "us-east1-c" 
install_config_sync "cymbal-staging" "us-central1-a" 
install_config_sync "cymbal-prod" "us-west1-a"
install_config_sync "cymbal-admin" "us-central1-f"