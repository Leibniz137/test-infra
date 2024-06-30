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

# TODO: make these configurable stored as vars
provider "google" {
  //   credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY>.json")
  project = "firewall-426619"
  region  = "us-west2"
  zone    = "us-west2-c"
}

# test delete bucket
# resource "google_storage_bucket" "test-bucket" {
#   name     = "test-bucket-9777"
#   location = "us-west2"
# }

resource "google_compute_address" "static_ip" {
  name = "firewall"
}

# test delete vm
resource "google_compute_instance" "e2_micro" {
  name         = "e2-micro-instance"
  machine_type = "e2-micro"
  # see: https://cloud.google.com/free/docs/free-cloud-features#always-free-usage-limits
  zone = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    username = "firewall"
    ssh-keys = "firewall:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCuF4IYOJjN65jbw4gbyjpmrwuuUNkTWJ4PiMXW4rgiq2iwpgdaxz6UCq3LtOpG0+lYuLFhDiuSCA9DRQsktGStt9+jJDvjVD3RJZpBJedusZNQJ1RnC8/jje8KQjjbFOJXcBxyLP96jzi112lh/qUCjk8cMgiUg3xGQq/esY7125oiZFVELL85EvCfAGSh3Y8Gy6BWRw/rjxJ2A9pn0jd9c2WbgclekCpUB7QFmAdD33vx6vbGwIImNoM+a63Hh/wyjWhTRJoO8s++I1NeaAK2xwNa02dxX5KWEXKaHTNaSV1WzO9Dp0iJ/t+RaMusnEZVl6yG9uPW8WDnDUA4zSfCcd0VIKpi+yhoRy2JxidoqVUqrREMVneo0P2StXd8ARzm2dGwgGg36td+Ge+eOrG3DvorYR9NvJzmLPbahvNz85bar6uK7Q7Ay8nB86O4AQgpPHuHG+Dy4LWJpQOGldnOkEkTFeRo0iqCcqIy+wezkn7/6y+5Ev2oC0gcIp/RRDOpRih94Wewp+wiI2mKxYFlGYPVv/g+WcrrujwvVhkQVEW0qH0qJQXvmEE6rDprGY/G/soD1Zj8RnzmjFBdCgstGxYzEvkMLnKc2w0z54bMheW13D8J9VWc5i1Ky2s0DUHdbaP7P7yKwBpRxvjLFSFTSHoHwyRFY0PjpVOq9o1rQ== iac-automation"
  }

}