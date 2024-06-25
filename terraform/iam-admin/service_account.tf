// bucket for storing tf state

resource "google_storage_bucket" "terraform_state" {
  // 94439 is a random number
  name          = "terraform-state-bucket-94439"
  location      = "us-west2"
  storage_class = "STANDARD"
}

// creates service account for use in github actions

resource "google_service_account" "terraform_sa" {
  account_id   = "terraform-sa"
  display_name = "Terraform Service Account"
}

# roles/iam.serviceAccountTokenCreator role is required
resource "google_project_iam_binding" "terraform_sa_binding" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.terraform_sa.email}",
  ]
}

resource "google_project_iam_custom_role" "cicd_role" {
  project     = var.project_id
  role_id     = "cicd_role"
  title       = "Role for CI/CD pipeline"
  description = "A demo role with permissions for maintaining testnet"

  permissions = [
    // permissions for accessing state bucket
    "storage.objects.list",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.buckets.list",

    // additional permissions for bucket creation / removal
    "storage.buckets.create",
    "storage.buckets.get",
    "storage.buckets.delete",
  ]
}

resource "google_project_iam_binding" "cicd_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.cicd_role.id

  members = [
    "serviceAccount:${google_service_account.terraform_sa.email}",
  ]
}

# This doesn't seem to work...
# resource "google_project_iam_binding" "object_creator_sa_binding" {
#   project = var.project_id
#   role    = "roles/storage.objectCreator"

#   members = [
#     "serviceAccount:${google_service_account.terraform_sa.email}",
#   ]
# }

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

  project             = var.project_id
  display_name        = "My GitHub repo Provider"
  description         = "Identity pool provider for automated test"
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 3. Get the full ID of the Workload Identity Pool
output "workload_identity_pool_provider_id" {
  value = google_iam_workload_identity_pool_provider.sequencer_repo.name
}

# fixes "IAM Service Account Credentials API has not been used in project 812684586228 before or it is disabled."
resource "google_project_service" "iamcredentials" {
  project = var.project_id

  # service to enable
  service = "iamcredentials.googleapis.com"

  # If true, services that are enabled and which depend on this service should also be disabled when this service is destroyed.
  # If false or unset, an error will be returned if any enabled services depend on this service when attempting to destroy it.
  disable_dependent_services = false

  # If true or unset, disable the service when the Terraform resource is destroyed.
  # If false, the service will be left enabled when the Terraform resource is destroyed.
  # Defaults to true. Most configurations should set this to false;
  # it should generally only be true or unset in configurations that manage the google_project resource itself.
  disable_on_destroy = false
}

# fixes "Error 403: Compute Engine API has not been used in project firewall-426619 before or it is disabled."
resource "google_project_service" "compute" {
  project = var.project_id

  # service to enable
  service = "compute.googleapis.com"

  # If true, services that are enabled and which depend on this service should also be disabled when this service is destroyed.
  # If false or unset, an error will be returned if any enabled services depend on this service when attempting to destroy it.
  disable_dependent_services = false

  # If true or unset, disable the service when the Terraform resource is destroyed.
  # If false, the service will be left enabled when the Terraform resource is destroyed.
  # Defaults to true. Most configurations should set this to false;
  # it should generally only be true or unset in configurations that manage the google_project resource itself.
  disable_on_destroy = false
}

# fixes: "Permission 'iam.serviceAccounts.getAccessToken' denied on resource (or it may not exist)."
resource "google_service_account_iam_binding" "allow_impersonation" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    # TODO: interpolate project id variable 812...
    "principalSet://iam.googleapis.com/projects/812684586228/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository_owner/${var.github_org}",
  ]
}