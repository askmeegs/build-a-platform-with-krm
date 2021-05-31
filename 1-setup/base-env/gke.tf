# Terraform resources for the 4 GKE clusters used for this demo: admin, dev, staging, prod. 

# Source: https://github.com/hashicorp/learn-terraform-provision-gke-cluster/
# https://learn.hashicorp.com/tutorials/terraform/gke 

# Each GKE cluster will have 4 nodes. 
variable "gke_num_nodes" {
  default     = 4
  description = "number of gke nodes"
}

# ☁️ ADMIN CLUSTER (used in Part 5 for Config Connector)
resource "google_container_cluster" "admin" {
  project = var.project_id 
  provider = google-beta
  # name is the GKE cluster name. 
  name     = "cymbal-admin"
  # location is the GCP zone your GKE cluster is deployed to. 
  location = "us-central1-f"

  # we're going to deploy a custom node pool, below. 
  remove_default_node_pool = true
  initial_node_count = 1

  #  all clusters have Workload Identity enabled, which allows you to connect 
  # a Google Service Account with specific roles to your Kubernetes Workloads. 
  # (instead of the default which is to have your GKE nodes have the default GCE 
  # service account - which has sweeping permissions on your project.)
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  # the admin cluster has the Config Connector GKE add-on.  
  addons_config {
    config_connector_config {
      enabled = true
    }
  }
}

# Admin cluster - node pool 
# GKE cluster can have 1 or more node pools.
# node pools are collections of GCE instances that can scale up or down.
#  here we have 1 node pool with 4 nodes. 
resource "google_container_node_pool" "admin-nodes" {
  project = var.project_id 
  name       = "${google_container_cluster.admin.name}-node-pool"
  location   = "us-central1-f"
  cluster    = google_container_cluster.admin.name
  node_count = var.gke_num_nodes

  # GKE Node scopes are permissions for the nodes themselves: 
  # https://cloud.google.com/sdk/gcloud/reference/container/clusters/create#--scopes
  # (whereas workload identity is the permissions for the Pods that run *on* the nodes.)
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform", 
      "https://www.googleapis.com/auth/devstorage.read_only", 
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append", 
    ]

    labels = {
      env = var.project_id
    }

    machine_type = "e2-standard-4"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# 💻 DEVELOPMENT CLUSTER 
resource "google_container_cluster" "dev" {
  project = var.project_id 
  name     = "cymbal-dev"
  location = "us-east1-c"

  remove_default_node_pool = true
  initial_node_count = 1

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

}

# Separately Managed Node Pool
resource "google_container_node_pool" "dev-nodes" {
  project = var.project_id 
  name       = "${google_container_cluster.dev.name}-node-pool"
  location   = "us-east1-c"
  cluster    = google_container_cluster.dev.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform", 
      "https://www.googleapis.com/auth/devstorage.read_only", 
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append", 
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "e2-standard-4"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# 🏁 STAGING CLUSTER 
resource "google_container_cluster" "staging" {
  project = var.project_id 
  name     = "cymbal-staging"
  location = "us-central1-a"

  remove_default_node_pool = true
  initial_node_count = 1

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

}

# Separately Managed Node Pool
resource "google_container_node_pool" "staging-nodes" {
  project = var.project_id 
  name       = "${google_container_cluster.staging.name}-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.staging.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform", 
      "https://www.googleapis.com/auth/devstorage.read_only", 
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append", 
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "e2-standard-4"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# 🚀 PRODUCTION CLUSTER 
resource "google_container_cluster" "prod" {
  project = var.project_id 
  name     = "cymbal-prod"
  location = "us-west1-a"

  remove_default_node_pool = true
  initial_node_count = 1

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

}

# Separately Managed Node Pool
resource "google_container_node_pool" "prod-nodes" {
  project = var.project_id 
  name       = "${google_container_cluster.prod.name}-node-pool"
  location   = "us-west1-a"
  cluster    = google_container_cluster.prod.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform", 
      "https://www.googleapis.com/auth/devstorage.read_only", 
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append", 
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "e2-standard-4"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}