
# Initializing service accounts and secrets

These steps are to be performed as a one-time setup procedure by an admin.

```
# make sure you have gcloud installed
brew install google-cloud-sdk   # assuming os x

# login to gcloud
gcloud auth application-default login

# initialize terraform + gcp provider
cd terraform/iam-admin
terraform init

# create service account for use in github actions pipeline
terraform plan
terraform apply

# copy the "workload_identity_pool_provider_id" output
# and set the `workload_identity_provider` in the .github/workflows/ci.yml to this value
```