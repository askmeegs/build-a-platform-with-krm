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
    echo "********** Installing Config Sync: $CLUSTER_NAME, zone: $CLUSTER_ZONE ***************" 

    kubectx $CLUSTER_NAME 
    kubectl apply -f config-sync-operator.yaml

    # inject github username into Config Management YAML + apply 
    CRD_FILE="config-management-crds/${CLUSTER_NAME}.yaml"
    gsed -i "s/GITHUB_USERNAME/${GITHUB_USERNAME}/g" $CRD_FILE

    # install config sync by applying the CRD 
    gcloud alpha container hub config-management apply \
        --membership=${CLUSTER_NAME} \
        --config=config-management-crds/${CLUSTER_NAME}.yaml \
        --project=${PROJECT_ID}
}

# Download Config Sync operator 
# gsutil cp gs://config-management-release/released/latest/config-sync-operator.yaml config-sync-operator.yaml

# Install Config Sync on dev, staging, and prod 
install_config_sync "cymbal-dev" "us-east1-c" 
install_config_sync "cymbal-staging" "us-central1-a" 
install_config_sync "cymbal-prod" "us-west1-a"