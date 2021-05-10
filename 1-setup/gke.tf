# Source: https://github.com/hashicorp/learn-terraform-provision-gke-cluster/
# https://learn.hashicorp.com/tutorials/terraform/gke 

# VARIABLES 
variable "gke_num_nodes" {
  default     = 4
  description = "number of gke nodes"
}

# ☁️ ADMIN CLUSTER (Config Connector)
resource "google_container_cluster" "admin" {
  project = var.project_id 
  provider = google-beta
  name     = "cymbal-admin"
  location = "us-central1-f"

  remove_default_node_pool = true
  initial_node_count = 1

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  addons_config {
    config_connector_config {
      enabled = true
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "admin-nodes" {
  project = var.project_id 
  name       = "${google_container_cluster.admin.name}-node-pool"
  location   = "us-central1-f"
  cluster    = google_container_cluster.admin.name
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

# 💻 DEVELOPMENT CLUSTER 
resource "google_container_cluster" "dev" {
  project = var.project_id 
  name     = "cymbal-dev"
  location = "us-east1-c"

  remove_default_node_pool = true
  initial_node_count = 1

  # network    = google_compute_network.vpc.name
  # subnetwork = google_compute_subnetwork.subnet.name

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

  # network    = google_compute_network.vpc.name
  # subnetwork = google_compute_subnetwork.subnet.name

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

  # network    = google_compute_network.vpc.name
  # subnetwork = google_compute_subnetwork.subnet.name

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