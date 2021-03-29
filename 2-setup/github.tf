# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository 

# https://www.hashicorp.com/blog/managing-github-with-terraform 


variable "github_token" {
  type = string
  description = "Github personal access token"
}


provider "github" {
  token = var.github_token
}

# App Source Repo 
resource "github_repository" "example" {
  name        = "cymbalbank-app-source"
  description = "Intro to KRM Demo: CymbalBank - Application Source"

  visibility  = "public"
}

# App Config Repo 
resource "github_repository" "example" {
  name        = "cymbalbank-app-config"
  description = "Intro to KRM Demo: CymbalBank - Application Manifests"

  visibility  = "public"
}

# Policy Repo 
resource "github_repository" "example" {
  name        = "cymbalbank-policy"
  description = "Intro to KRM Demo: CymbalBank - ConfigSync Policy Repo"

  visibility  = "public"
}