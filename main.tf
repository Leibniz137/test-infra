terraform {
  backend "gcs" {
    bucket = "terraform-state-bucket-94439"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      // https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
      version = "5.33.0"
    }
  }
}

# TODO: make these configurable stored as vars
provider "google" {
  //   credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY>.json")
  project = "firewall-426619"
  region  = "us-west2"
  zone    = "us-west2-c"
}

# test delete bucket
# resource "google_storage_bucket" "test-bucket" {
#   name     = "test-bucket-9777"
#   location = "us-west2"
# }


resource "google_compute_instance" "f1_micro" {
  name         = "f1-micro-instance"
  machine_type = "f1-micro"
  zone         = "us-west2-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}