# Here, we use the Google Cloud provider for Terraform as a dependency. 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.62.0"
    }
  }
}
