#!/bin/bash 

# KSA = Kubernetes Service Account 
# GSA = Google Service Account 
# Workload Identity allows a KSA to act as a GSA, with fine-grained IAM permissions. 
# for each K8s namespace that needs Cloud SQL access, we will create a KSA, and map each to the same GSA (cymbal-test-gsa), which has specific Cloud SQL access permissions. Then, the K8s pods will use the newly-created KSA, allowing cloud-sql-proxy to authenticate to Cloud SQL. 

# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#identity_sameness_across_clusters 


export KSA_NAME="cymbal-test-ksa"
export GSA_NAME="cymbal-test-gsa"
export INSTANCE_NAME='cymbal-test-db'

gcloud config set project ${PROJECT_ID}

echo "🔐 Setting up workload identity."
echo "✅ Creating Google Service Account with Cloud SQL roles..."
gcloud iam service-accounts create $GSA_NAME

echo "✅ Granting Service account permissions..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/cloudtrace.agent

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/monitoring.metricWriter

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role roles/cloudsql.client

# NS LOOP 
echo "✅ Creating KSAs in each CymbalBank namespace..."
declare -a NAMESPACES=("balancereader" "transactionhistory" "ledgerwriter" "contacts" "userservice" "frontend" "loadgenerator")

for ns in "${NAMESPACES[@]}"
do
  echo "🔁 Setting up namespace: ${ns}"
  # create namespace  
  kubectl create namespace $ns 

  # create ksa 
  kubectl create serviceaccount --namespace $ns $KSA_NAME

  # connect KSA to GSA (many to 1)
  kubectl annotate serviceaccount \
    --namespace $ns \
    $KSA_NAME \
    iam.gke.io/gcp-service-account=$GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com
  
  gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[$ns/$KSA_NAME]" \
  $GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com
done 

# CREATE CLOUD SQL INSTANCE 
echo "☁️ Enabling the Cloud SQL API..."
gcloud services enable sqladmin.googleapis.com

echo "☁️ Creating Cloud SQL instance: ${INSTANCE_NAME} ..."
gcloud sql instances create $INSTANCE_NAME \
    --database-version=POSTGRES_12 --tier=db-custom-1-3840 \
    --region=${REGION} --project ${PROJECT_ID}

echo "☁️ Creating admin user..."
gcloud sql users create admin \
   --instance=$INSTANCE_NAME --password=admin

# Create Accounts DB
echo "☁️ Creating accounts-db in ${INSTANCE_NAME}..."
gcloud sql databases create accounts-db --instance=$INSTANCE_NAME

# Create Ledger DB
echo "☁️ Creating ledger-db in ${INSTANCE_NAME}..."
gcloud sql databases create ledger-db --instance=$INSTANCE_NAME

echo "⭐️ Created database: ${INSTANCE_NAME} in ${REGION}"

# Create DB credentials for cloud-sql-proxy 
INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe $INSTANCE_NAME --format='value(connectionName)')

echo "🔑 Creating Cloud SQL secrets for each app namespace"
for ns in "${NAMESPACES[@]}"
do
  kubectl create secret -n ${ns} generic cloud-sql-admin \
  --from-literal=username=admin --from-literal=password=admin \
  --from-literal=connectionName=${INSTANCE_CONNECTION_NAME}
done 

