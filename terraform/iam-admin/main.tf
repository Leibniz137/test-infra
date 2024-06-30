terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      // https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
      version = "5.33.0"
    }
  }
}

variable "project_id" {
  type    = string
  default = "firewall-426619"
}

# TODO: make these configurable stored as vars
provider "google" {
  project = var.project_id
  region  = "us-west2"
  zone    = "us-west2-c"
}

data "google_project" "project" {
  project_id = var.project_id
}