variable "gsa-name" {
  type = string
  description = "GSA Name for Workload Identity"
}

# Service account (GSA)
resource "google_service_account" "gsa" {
  account_id   = var.gsa_name
  display_name = "CymbalBank GSA"
}

# Cloud Trace, Monitoring, Cloud SQL permissions 

# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#   --member "serviceAccount:${GSA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
#   --role roles/cloudtrace.agent

resource "google_project_iam_binding" "cloud-trace-iam-binding" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"

  members = [
    "serviceAccount:${var.gsa_name}@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "cloud-monitoring-iam-binding" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${var.gsa_name}@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "cloud-sql-iam-binding" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:${var.gsa_name}@${var.project_id}.iam.gserviceaccount.com",
  ]
}
