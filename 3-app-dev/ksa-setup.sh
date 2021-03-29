#!/bin/bash 


########### VARIABLES  ##################################
if [[ -z "$PROJECT_ID" ]]; then
    echo "Must provide PROJECT_ID in environment" 1>&2
    exit 1
fi

if [[ -z "$CLUSTER_NAME" ]]; then
    echo "Must provide CLUSTER_NAME in environment" 1>&2
    exit 1
fi

if [[ -z "$CLUSTER_ZONE" ]]; then
    echo "Must provide CLUSTER_ZONE in environment" 1>&2
    exit 1
fi


if [[ -z "$GSA_NAME" ]]; then
    echo "Must provide GSA_NAME in environment" 1>&2
    exit 1
fi


if [[ -z "$KSA_NAME" ]]; then
    echo "Must provide KSA_NAME in environment" 1>&2
    exit 1
fi

if [[ -z "$INSTANCE_NAME" ]]; then
    echo "Must provide INSTANCE_NAME (Cloud SQL) in environment" 1>&2
    exit 1
fi
############################################################



echo "☸️ Connecting to cluster ${CLUSTER_NAME}..."
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE} --project ${PROJECT_ID}


echo "✅ Creating KSAs in each CymbalBank namespace..."
declare -a NAMESPACES=("balancereader" "transactionhistory" "ledgerwriter" "contacts" "userservice" "frontend" "loadgenerator")

for ns in "${NAMESPACES[@]}"
do
  echo "🔁 Setting up namespace: ${ns}"
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

  # create cloud SQL secrets 
  echo "🔑 Creating Cloud SQL user secret for Instance: ${INSTANCE_NAME}"
  INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME --format='value(connectionName)')
  kubectl create secret -n ${ns} generic cloud-sql-admin \
    --from-literal=username=admin --from-literal=password=admin \
    --from-literal=connectionName=${INSTANCE_CONNECTION_NAME}
    
done 