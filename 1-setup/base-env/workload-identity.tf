# Terraform resources to set up Workload Identity authentication between the Cymbal Bank 
# application workloads and a Google Service Account with the minimum permissions 
# to export to Cloud Monitoring + Tracing, as well as read-write access to Cloud SQL    


# cymbal-gsa is the Google Service Account that we'll connect to the Cymbal Bank Kubernetes workloads 
resource "google_service_account" "cymbal-gsa" {
  project = var.project_id 
  account_id   = "cymbal-gsa"
  display_name = "cymbal-gsa"
}

# Give the cymbal-gsa service account Cloud Trace export access. 
resource "google_project_iam_binding" "cloud-trace-iam-binding" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"

  members = [
    "serviceAccount:cymbal-gsa@${var.project_id}.iam.gserviceaccount.com",
  ]
}

# Give the cymbal-gsa service account Cloud Monitoring export access. 
resource "google_project_iam_binding" "cloud-monitoring-iam-binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:cymbal-gsa@${var.project_id}.iam.gserviceaccount.com",
  ]
}

# Give the cymbal-gsa service account Cloud SQL access. 
resource "google_project_iam_binding" "cloud-sql-iam-binding" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:cymbal-gsa@${var.project_id}.iam.gserviceaccount.com",
  ]
}
