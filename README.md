This repo triggers the automation creation of cloud resources in google.
This repo requires initializing


# Initial Admin setup

These steps are to be performed as a one-time setup procedure by an admin.

## 1. install dependencies

```
# make sure you have gcloud installed
brew install google-cloud-sdk   # assuming os x
brew install terraform
```

## 2. initialize terraform
```
# login to gcloud
gcloud auth application-default login

# initialize terraform + gcp provider
cd terraform/iam-admin
terraform init
```

## 3. create service-accounts, roles, etc.
```
# create service account for use in github actions pipeline
terraform plan
terraform apply
```

## 4. set the output in terraform

When running the iam-admin terraform, you'll see something like this:
```
...
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

workload_identity_pool_provider_id = "projects/812684586228/locations/global/workloadIdentityPools/github/providers/github-provider"
```

Copy the "workload_identity_pool_provider_id" output and set the `workload_identity_provider` field in the [.github/workflows/ci.yml](./.github/workflows/ci.yml) to this value.
```