terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      // https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
      version = "5.33.0"
    }
  }
}

provider "google" {
  //   credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY>.json")
  project = "firewall-426619"
  region  = "us-west2"
  zone    = "us-central1-c"
}
