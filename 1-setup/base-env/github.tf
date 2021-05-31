# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository 

# https://www.hashicorp.com/blog/managing-github-with-terraform 

provider "github" {
  token = var.github_token
}

# App Source Repo 
resource "github_repository" "app-source" {
  name        = "cymbalbank-app-source"
  description = "Build a Platform with KRM Demo: Application Source"

  visibility  = "public"
}

# App Config Repo 
resource "github_repository" "app-config" {
  name        = "cymbalbank-app-config"
  description = "Build a Platform with KRM Demo: Application Config"

  visibility  = "public"
}

# Policy Repo 
resource "github_repository" "policy" {
  name        = "cymbalbank-policy"
  description = "Build a Platform with KRM Demo: Policy Repo"

  visibility  = "public"
}