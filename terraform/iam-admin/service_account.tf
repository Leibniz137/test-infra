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

    // additional permissions for vm creation / removal
    "compute.addresses.create",
    "compute.addresses.delete",
    "compute.addresses.get",
    "compute.instances.setMetadata",
    "compute.addresses.use",
    "compute.disks.create",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.get",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.zones.get",
  ]
}

resource "google_project_iam_binding" "cicd_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.cicd_role.id

  members = [
    "serviceAccount:${google_service_account.terraform_sa.email}",
  ]
}

// service account to be used by virtual machine
resource "google_service_account" "virtual_machine_sa" {
  account_id   = "virtual-machine-sa"
  display_name = "Virtual Machine Service Account"
}

resource "google_project_iam_custom_role" "virtual_machine_role" {
  role_id     = "virtual_machine_role"
  title       = "Virtual machine role"
  description = "Role for VMs to publish to Pub/Sub"

  permissions = [
    "pubsub.topics.publish",
    # Add any other required permissions here
  ]
}

resource "google_project_iam_binding" "vm_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.virtual_machine_role.id

  members = [
    "serviceAccount:${google_service_account.virtual_machine_sa.email}",
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

# fixes: "Permission 'iam.serviceAccounts.getAccessToken' denied on resource (or it may not exist)."
resource "google_service_account_iam_binding" "allow_impersonation" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository_owner/${var.github_org}",
  ]
}