#!/bin/bash 


########### VARIABLES  ##################################
if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi


# Anthos registration 
export MEMBERSHIP_NAME="anthos-membership"
export SERVICE_ACCOUNT_NAME="register-sa"

# Cymbal app 
export KSA_NAME="cymbal-ksa"
export GSA_NAME="cymbal-gsa"

############################################################

register_cluster () {
    CLUSTER_NAME=$1 
    CLUSTER_ZONE=$2 
    echo "🏔 Registering cluster to Anthos: $CLUSTER_NAME, zone: $CLUSTER_ZONE" 
    kubectx ${CLUSTER_NAME} 

    URI="https://container.googleapis.com/v1/projects/${PROJECT_ID}/zones/${CLUSTER_ZONE}/clusters/${CLUSTER_NAME}"
    gcloud container hub memberships register ${CLUSTER_NAME} \
    --project=${PROJECT_ID} \
    --gke-uri=${URI} \
    --service-account-key-file=register-key.json
}

setup_cluster () {
    CLUSTER_NAME=$1 
    CLUSTER_ZONE=$2 
    echo "☸️ Setting up cluster: $CLUSTER_NAME, zone: $CLUSTER_ZONE" 
    gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE} --project ${PROJECT_ID} 
    kubectx ${CLUSTER_NAME}=. 

    echo "💡 Creating a Kubernetes Service Account (KSA) for each CymbalBank namespace..."
    declare -a NAMESPACES=("balancereader" "transactionhistory" "ledgerwriter" "contacts" "userservice" "frontend" "loadgenerator")

    for ns in "${NAMESPACES[@]}"
    do
        echo "****** 🔁 Setting up namespace: ${ns} ********"
        # boostrap namespace 
        kubectl create namespace $ns 

        # boostrap ksa 
        kubectl create serviceaccount --namespace $ns $KSA_NAME

        # connect KSA to GSA (many to 1)
        echo "☁️ Allowing KSA: ${KSA_NAME} to act as GSA: ${GSA_NAME}"
        kubectl annotate serviceaccount \
            --namespace $ns \
            $KSA_NAME \
            iam.gke.io/gcp-service-account=$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com
        
        gcloud iam service-accounts add-iam-policy-binding \
            --role roles/iam.workloadIdentityUser \
            --member "serviceAccount:${PROJECT_ID}.svc.id.goog[$ns/$KSA_NAME]" \
            $GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com

        # create cloud SQL secrets. cluster and instance names are the same, ie. cymbal-dev is the name of both the dev GKE cluster and the dev Cloud SQL DB  
        echo "🔑 Creating Cloud SQL user secret for Instance: ${CLUSTER_NAME}"
        INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $CLUSTER_NAME --format='value(connectionName)')
        kubectl create secret -n ${ns} generic cloud-sql-admin \
            --from-literal=username=admin --from-literal=password=admin \
            --from-literal=connectionName=${INSTANCE_CONNECTION_NAME}  
    done 
    echo "⭐️ Done with cluster: ${CLUSTER_NAME}"
    }

kubeconfig for admin cluster 
gcloud config set project ${PROJECT_ID}

echo "☁️  Connecting to the admin cluster for later..."
gcloud container clusters get-credentials cymbal-admin --zone us-central1-f --project ${PROJECT_ID} 
kubectx cymbal-admin=. 

echo "Enabling Anthos APIs..."
gcloud services enable anthos.googleapis.com 
gcloud alpha container hub config-management enable

# Set up project for Anthos / project-wide service account
echo "🔑 Creating Anthos registration service account..."
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} --project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
 --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
 --role="roles/gkehub.connect"

echo "🔑 Downloading service account key..."
gcloud iam service-accounts keys create register-key.json \
  --iam-account=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
  --project=${PROJECT_ID}

Set up clusters for the CymbalBank app 
setup_cluster "cymbal-dev" "us-east1-c" 
setup_cluster "cymbal-staging" "us-central1-a" 
setup_cluster "cymbal-prod" "us-west1-a"

# Register all 4 clusters to the Anthos dashboard
register_cluster "cymbal-dev" "us-east1-c" 
register_cluster "cymbal-staging" "us-central1-a" 
register_cluster "cymbal-prod" "us-west1-a"
register_cluster "cymbal-admin" "us-central1-f"

echo "✅ GKE Cluster Setup Complete."



