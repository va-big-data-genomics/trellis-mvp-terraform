/*
|--------------------------------------------------------------------------
| Bastion Node
|--------------------------------------------------------------------------
|
| Bastion node 
|
*/

resource "google_compute_instance" "bastion-node" {
    name = "bastion-external-${var.unique-id}"
    machine_type = "g1-small"
    zone = "us-west1-a"
    
    tags = ["bastion"]

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-9"
            size = "10"
        }
    }
    
    network_interface {
        network = google_compute_network.bastion-network.self_link
        subnetwork = google_compute_subnetwork.bastion-subnet.self_link

        access_config {
           // nat_ip = var.bastion-ip
        }
    }
}
