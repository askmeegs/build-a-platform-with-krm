variable "gsa-name" {
  type = string
  description = "GSA Name for Workload Identity"
}

# Service account (GSA)
resource "google_service_account" "gsa" {
  account_id   = "cymbal-gsa"
  display_name = "CymbalBank GSA"
}

# Cloud Trace, Monitoring, Cloud SQL permissions 
resource "google_project_iam_binding" "cloud-trace-iam-binding" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"

  members = [
    "serviceAccount:cymbal-gsa@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "cloud-monitoring-iam-binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:cymbal-gsa@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "cloud-sql-iam-binding" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:cymbal-gsa@${var.project_id}.iam.gserviceaccount.com",
  ]
}
