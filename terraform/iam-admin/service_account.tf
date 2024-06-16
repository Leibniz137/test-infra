// creates service account for use in github actions

resource "google_service_account" "terraform_sa" {
  account_id   = "terraform-sa"
  display_name = "Terraform Service Account"
}

resource "google_service_account_key" "terraform_sa_key" {
  service_account_id = google_service_account.terraform_sa.name
}

resource "local_file" "service_account_key_file" {
  content     = google_service_account_key.terraform_sa_key.private_key
  filename = "${path.module}/terraform_sa_key.json"
}

output "service_account_email" {
  value = google_service_account.terraform_sa.email
}