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
  type    = string
  default = "firewall-426619"
}

# TODO: make these configurable stored as vars
provider "google" {
  //   credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY>.json")
  project = var.project_id
}

// ssh keys to access VM
variable "ssh_public_keys" {
  type = list(string)
  default = [
    "firewall:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCuF4IYOJjN65jbw4gbyjpmrwuuUNkTWJ4PiMXW4rgiq2iwpgdaxz6UCq3LtOpG0+lYuLFhDiuSCA9DRQsktGStt9+jJDvjVD3RJZpBJedusZNQJ1RnC8/jje8KQjjbFOJXcBxyLP96jzi112lh/qUCjk8cMgiUg3xGQq/esY7125oiZFVELL85EvCfAGSh3Y8Gy6BWRw/rjxJ2A9pn0jd9c2WbgclekCpUB7QFmAdD33vx6vbGwIImNoM+a63Hh/wyjWhTRJoO8s++I1NeaAK2xwNa02dxX5KWEXKaHTNaSV1WzO9Dp0iJ/t+RaMusnEZVl6yG9uPW8WDnDUA4zSfCcd0VIKpi+yhoRy2JxidoqVUqrREMVneo0P2StXd8ARzm2dGwgGg36td+Ge+eOrG3DvorYR9NvJzmLPbahvNz85bar6uK7Q7Ay8nB86O4AQgpPHuHG+Dy4LWJpQOGldnOkEkTFeRo0iqCcqIy+wezkn7/6y+5Ev2oC0gcIp/RRDOpRih94Wewp+wiI2mKxYFlGYPVv/g+WcrrujwvVhkQVEW0qH0qJQXvmEE6rDprGY/G/soD1Zj8RnzmjFBdCgstGxYzEvkMLnKc2w0z54bMheW13D8J9VWc5i1Ky2s0DUHdbaP7P7yKwBpRxvjLFSFTSHoHwyRFY0PjpVOq9o1rQ== iac-automation",
    "firewall:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC30owd2/cHHVpnnAdrD8AsE8ArKAw/+NLw3LhrIn10YCl2Rs/lea8bygPkGzyheidperf/EGvE4DrrxSZwaNoK+fWgB30poMhhYk3C5l8+yDKi/kXcrSgLYl4e2y0DryD+//QkshB/jANo1rxhIpdsOiEF9eIZG1YRr9KgweAZ2D+nn0CIWaRvjvals2GETI1sj5loWyh4KDIyE23HJ/qvIfXL6J6Co2H9YIacAimNq2Ggqhpp0j9o8SeDHVfGljLDpoXLhdLQCVXphzf6pcSlDGQPnWYO2ebcaZEEkBfOWZ+6+uSTJ1Gn2LU967ceTwIKY/Dhpg8W/ukB7vwNIluVW2fsPl34b/A7ebDhk6TaWnUfYXY47adS941XdGNu/1E99RVTjy/lppxFVUuxCH+YzKhHkHF5YNET6ibHyPONDvbgUX4u3AHl1WPB9dus4vKrbXr/LOnPdIYDq3rytQVUv80F1sVeLUXu/9BiJkH2ORkF8vlOfOxNcfANFYtmxFLID8niM/W3wbsvVrAUL86Z4Kszcs7kUKXGgUkKOhVSiCkXEUAXzmq6SdsgYkpgps7PAoi5E1DzIv5DmLSlJV047wNTlF9xnR9p+/Z3IbrQ3LSaRLDVBt3mFTBVVpkEobXveBd+7dVM5HTRqb9Ktitn+lS66tCp3bodzmL9lTP5Hw== test",
  ]
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

# resource "google_pubsub_topic" "test_infra" {
#   name = "test-infra-topic"

#   labels = {
#     test = "infra"
#   }

#   message_retention_duration = "86600s"
# }

resource "google_compute_address" "static_ip" {
  name   = "firewall"
  region = var.region
}


# test delete vm
resource "google_compute_instance" "e2_micro" {
  name         = "e2-micro-instance"
  machine_type = "e2-micro"
  # see: https://cloud.google.com/free/docs/free-cloud-features#always-free-usage-limits
  zone = local.zone


  /*
  Fixes (which wasn't encountered in this repo, only in iac repo 🤔):
  ╷
  │ Error: Changing the machine_type, min_cpu_platform, service_account, enable_display, shielded_instance_config, scheduling.node_affinities or network_interface.[#d].(network/subnetwork/subnetwork_project) or advanced_machine_features on a started instance requires stopping it. To acknowledge this, please set allow_stopping_for_update = true in your config. You can also stop it by setting desired_status = "TERMINATED", but the instance will not be restarted after the update.
  │ 
  │   with google_compute_instance.e2_micro,
  │   on main.tf line 51, in resource "google_compute_instance" "e2_micro":
  │   51: resource "google_compute_instance" "e2_micro" {
  │ 
  ╵
  */
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = <<EOF
    #!/bin/bash

    # installation directions here: https://docs.docker.com/engine/install/debian/

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # To install the latest version, run:
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Verify that the installation is successful by running the hello-world image:
    sudo docker run hello-world

    # allow firewall user to run docker commands
    sudo groupadd docker
    sudo usermod -aG docker firewall
  EOF

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    username = "firewall"
    ssh-keys = join(" \n", var.ssh_public_keys)
  }

  service_account {
    email  = data.google_service_account.virtual_machine_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  tags = ["testnet", "sequencer"]

}

output "static_ip_address" {
  value = google_compute_address.static_ip.address
}

resource "google_compute_instance" "e2_micro_replica" {
  name         = "e2-micro-instance-replica"
  machine_type = "e2-micro"
  # see: https://cloud.google.com/free/docs/free-cloud-features#always-free-usage-limits
  zone = local.zone


  /*
  Fixes (which wasn't encountered in this repo, only in iac repo 🤔):
  ╷
  │ Error: Changing the machine_type, min_cpu_platform, service_account, enable_display, shielded_instance_config, scheduling.node_affinities or network_interface.[#d].(network/subnetwork/subnetwork_project) or advanced_machine_features on a started instance requires stopping it. To acknowledge this, please set allow_stopping_for_update = true in your config. You can also stop it by setting desired_status = "TERMINATED", but the instance will not be restarted after the update.
  │ 
  │   with google_compute_instance.e2_micro,
  │   on main.tf line 51, in resource "google_compute_instance" "e2_micro":
  │   51: resource "google_compute_instance" "e2_micro" {
  │ 
  ╵
  */
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = <<EOF
    #!/bin/bash

    # installation directions here: https://docs.docker.com/engine/install/debian/

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # To install the latest version, run:
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Verify that the installation is successful by running the hello-world image:
    sudo docker run hello-world

    # allow firewall user to run docker commands
    sudo groupadd docker
    sudo usermod -aG docker firewall
  EOF

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    username = "firewall"
    ssh-keys = join(" \n", var.ssh_public_keys)
  }

  # service_account {
  #   email  = data.google_service_account.virtual_machine_sa.email
  #   scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  # }

  tags = ["testnet", "replica"]

}