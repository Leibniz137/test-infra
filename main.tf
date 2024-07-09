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

variable "region" {
  type    = string
  default = "us-west1"
}

locals {
  zone = "${var.region}-a"
}

variable "project_id" {
  type = string
  default = "firewall-426619"
}

# TODO: make these configurable stored as vars
provider "google" {
  //   credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY>.json")
  project = var.project_id
}

# test delete bucket
# resource "google_storage_bucket" "test-bucket" {
#   name     = "test-bucket-9777"
#   location = "us-west2"
# }

data "google_service_account" "virtual_machine_sa" {
  # NOTE: must match what is defined in admin terraform
  account_id = "virtual-machine-sa"
}

resource "google_pubsub_topic" "test_infra" {
  name = "test-infra-topic"

  labels = {
    test = "infra"
  }

  message_retention_duration = "86600s"
}

# resource "google_compute_address" "static_ip" {
#   name   = "firewall"
#   region = var.region
# }

# # test delete vm
# resource "google_compute_instance" "e2_micro" {
#   name         = "e2-micro-instance"
#   machine_type = "e2-micro"
#   # see: https://cloud.google.com/free/docs/free-cloud-features#always-free-usage-limits
#   zone = local.zone

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   metadata_startup_script = <<EOF
#     #!/bin/bash

#     # installation directions here: https://docs.docker.com/engine/install/debian/

#     # Add Docker's official GPG key:
#     sudo apt-get update
#     sudo apt-get install -y ca-certificates curl
#     sudo install -m 0755 -d /etc/apt/keyrings
#     sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
#     sudo chmod a+r /etc/apt/keyrings/docker.asc

#     # Add the repository to Apt sources:
#     echo \
#       "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
#       $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#       sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#     sudo apt-get update

#     # To install the latest version, run:
#     sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#     # Verify that the installation is successful by running the hello-world image:
#     sudo docker run hello-world

#     # allow firewall user to run docker commands
#     sudo groupadd docker
#     sudo usermod -aG docker firewall
#   EOF

#   network_interface {
#     network = "default"
#     access_config {
#       nat_ip = google_compute_address.static_ip.address
#     }
#   }

#   metadata = {
#     username = "firewall"
#     ssh-keys = "firewall:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCuF4IYOJjN65jbw4gbyjpmrwuuUNkTWJ4PiMXW4rgiq2iwpgdaxz6UCq3LtOpG0+lYuLFhDiuSCA9DRQsktGStt9+jJDvjVD3RJZpBJedusZNQJ1RnC8/jje8KQjjbFOJXcBxyLP96jzi112lh/qUCjk8cMgiUg3xGQq/esY7125oiZFVELL85EvCfAGSh3Y8Gy6BWRw/rjxJ2A9pn0jd9c2WbgclekCpUB7QFmAdD33vx6vbGwIImNoM+a63Hh/wyjWhTRJoO8s++I1NeaAK2xwNa02dxX5KWEXKaHTNaSV1WzO9Dp0iJ/t+RaMusnEZVl6yG9uPW8WDnDUA4zSfCcd0VIKpi+yhoRy2JxidoqVUqrREMVneo0P2StXd8ARzm2dGwgGg36td+Ge+eOrG3DvorYR9NvJzmLPbahvNz85bar6uK7Q7Ay8nB86O4AQgpPHuHG+Dy4LWJpQOGldnOkEkTFeRo0iqCcqIy+wezkn7/6y+5Ev2oC0gcIp/RRDOpRih94Wewp+wiI2mKxYFlGYPVv/g+WcrrujwvVhkQVEW0qH0qJQXvmEE6rDprGY/G/soD1Zj8RnzmjFBdCgstGxYzEvkMLnKc2w0z54bMheW13D8J9VWc5i1Ky2s0DUHdbaP7P7yKwBpRxvjLFSFTSHoHwyRFY0PjpVOq9o1rQ== iac-automation"
#   }

# }

# output "static_ip_address" {
#   value = google_compute_address.static_ip.address
# }