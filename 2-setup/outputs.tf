output "kubernetes_dev_cluster_name" {
  value       = google_container_cluster.dev.name
  description = "GKE Dev Cluster Name"
}

output "kubernetes_staging_cluster_name" {
  value       = google_container_cluster.staging.name
  description = "GKE Staging Cluster Name"
}

output "kubernetes_prod_cluster_name" {
  value       = google_container_cluster.prod.name
  description = "GKE Prod Cluster Name"
}