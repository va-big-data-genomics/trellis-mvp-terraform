resource "google_compute_disk" "pd" {
    project = var.project
    name    = "disk-trellis-neo4j-data"
    type    = "pd-standard"
    zone    = var.zone
    size    = 1000
    labels  = {
        user = "trellis"
    }
}
