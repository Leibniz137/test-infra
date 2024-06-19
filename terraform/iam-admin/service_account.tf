// creates service account for use in github actions

resource "google_service_account" "terraform_sa" {
  account_id   = "terraform-sa"
  display_name = "Terraform Service Account"
}

variable "github_org" {
  type    = string
  default = "Leibniz137"
}

variable "project_id" {
  type    = string
  default = "firewall-426619"
}

variable "workload_identity_pool_id" {
  type    = string
  default = "github"
}

# "In this setup, the Workload Identity Pool has direct IAM permissions on Google Cloud resources;
# there are no intermediate service accounts or keys.
# This is preferred since it directly authenticates GitHub Actions to Google Cloud without a proxy resource.
# However, not all Google Cloud resources support principalSet identities.
# Please see the documentation for your Google Cloud service for more information."
#    - https://github.com/google-github-actions/auth/tree/v2/?tab=readme-ov-file#preferred-direct-workload-identity-federation


# 1. Create a Workload Identity Pool
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for automated test"
  disabled                  = false
  project                   = var.project_id
}

# 2. Create a Workload Identity Provider in that pool
resource "google_iam_workload_identity_pool_provider" "sequencer_repo" {
  # workload_identity_pool_id          = google_iam_workload_identity_pool.github.id
  workload_identity_pool_id          = var.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"

  project      = var.project_id
  display_name = "My GitHub repo Provider"
  description  = "Identity pool provider for automated test"
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"
  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}