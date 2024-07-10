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

# fixes "Identity and Access Management (IAM) API has not been used in project 812684586228 before or it is disabled."
resource "google_project_service" "iam" {
  project = var.project_id

  # service to enable
  service = "iam.googleapis.com"

  # If true, services that are enabled and which depend on this service should also be disabled when this service is destroyed.
  # If false or unset, an error will be returned if any enabled services depend on this service when attempting to destroy it.
  disable_dependent_services = false

  # If true or unset, disable the service when the Terraform resource is destroyed.
  # If false, the service will be left enabled when the Terraform resource is destroyed.
  # Defaults to true. Most configurations should set this to false;
  # it should generally only be true or unset in configurations that manage the google_project resource itself.
  disable_on_destroy = false
}

# fixes "Cloud Pub/Sub API has not been used in project 812684586228 before or it is disabled."
resource "google_project_service" "pubsub" {
  project = var.project_id

  # service to enable
  service = "pubsub.googleapis.com"

  # If true, services that are enabled and which depend on this service should also be disabled when this service is destroyed.
  # If false or unset, an error will be returned if any enabled services depend on this service when attempting to destroy it.
  disable_dependent_services = false

  # If true or unset, disable the service when the Terraform resource is destroyed.
  # If false, the service will be left enabled when the Terraform resource is destroyed.
  # Defaults to true. Most configurations should set this to false;
  # it should generally only be true or unset in configurations that manage the google_project resource itself.
  disable_on_destroy = false
}