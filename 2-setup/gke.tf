# Source: https://github.com/hashicorp/learn-terraform-provision-gke-cluster/
# https://learn.hashicorp.com/tutorials/terraform/gke 

# VARIABLES 
variable "gke_num_nodes" {
  default     = 4
  description = "number of gke nodes"
}

# 💻 DEVELOPMENT CLUSTER 
resource "google_container_cluster" "dev" {
  name     = "cymbal-dev"
  location = "us-east1-a"

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
  name       = "${google_container_cluster.dev.name}-node-pool"
  location   = "us-east1-a"
  cluster    = google_container_cluster.dev.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
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
  name       = "${google_container_cluster.staging.name}-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.staging.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
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
  name       = "${google_container_cluster.prod.name}-node-pool"
  location   = "us-west1-a"
  cluster    = google_container_cluster.prod.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
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