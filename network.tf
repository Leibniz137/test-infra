# Create a firewall rule that allows traffic from the "source-vm" to the "target-vm" on ports 8651 and 8546
resource "google_compute_firewall" "replica-sequencer" {
  name    = "replica-sequencer"
  network = "default"

  allow {
    protocol = "tcp"
    ports = [
      // sequencer
      "8651",
      // geth L1 websocket
      "8546"
    ]
  }

  source_tags = ["replica"]
  target_tags = ["sequencer"]
}