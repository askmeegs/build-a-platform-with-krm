# Source: https://github.com/hashicorp/learn-terraform-provision-gke-cluster/
# https://learn.hashicorp.com/tutorials/terraform/gke 

# VARIABLES 
variable "gke_num_nodes" {
  default     = 4
  description = "number of gke nodes"
}

variable "dev-cluster-name" {
  type = string
  description = "Dev cluster name"
}

variable "dev-cluster-zone" {
  type = string
  description = "Dev cluster zone"
}


variable "staging-cluster-name" {
  type = string
  description = "staging cluster name"
}

variable "staging-cluster-zone" {
  type = string
  description = "staging cluster zone"
}


variable "prod-cluster-name" {
  type = string
  description = "prod cluster name"
}

variable "prod-cluster-zone" {
  type = string
  description = "prod cluster zone"
}

# 💻 DEVELOPMENT CLUSTER 
resource "google_container_cluster" "dev" {
  name     = var.dev-cluster-name
  location = var.dev-cluster-zone

  remove_default_node_pool = true
  initial_node_count = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "dev-nodes" {
  name       = "${google_container_cluster.dev.name}-node-pool"
  location   = var.dev-cluster-zone
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
  name     = var.staging-cluster-name
  location = var.staging-cluster-zone

  remove_default_node_pool = true
  initial_node_count = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "staging-nodes" {
  name       = "${google_container_cluster.staging.name}-node-pool"
  location   = var.staging-cluster-zone
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
  name     = var.prod-cluster-name
  location = var.prod-cluster-zone

  remove_default_node_pool = true
  initial_node_count = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

   workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "prod-nodes" {
  name       = "${google_container_cluster.prod.name}-node-pool"
  location   = var.prod-cluster-zone
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