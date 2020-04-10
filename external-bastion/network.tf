/*
|--------------------------------------------------------------------------
| Network Configuration
|--------------------------------------------------------------------------
|
| In order to run task VMs with only internal IP addresses, we need to 
| set up a Virtual Private Cloud (VPC) network. Here we will create a
| Trellis network, subnetwork, firewall rules, and a serverless VPC 
| connector.
|
*/

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

// Create bastion network
resource "google_compute_network" "bastion-network" {
    name = "trellis-bastion-${random_string.suffix.result}"
    auto_create_subnetworks = false
}    

// Create bastion subnet
resource "google_compute_subnetwork" "bastion-subnet" {
    name            = "bastion-${random_string.suffix.result}-us-west1"
    ip_cidr_range   = "10.0.0.0/9"
    region          = "us-west1"
    network         = google_compute_network.bastion-network.self_link
}

// Create firewall rule
resource "google_compute_firewall" "trellis-allow-local-ssh-bastion" {
    name = "trellis-allow-local-ssh-bastion"
    network = google_compute_network.bastion-network.self_link

    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    source_ranges = [var.local-ip]
    target_tags = ["bastion"]
}
