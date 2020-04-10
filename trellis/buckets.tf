resource "google_storage_bucket" "trellis" {
    name          = "${var.project}-trellis"
    location      = var.region
    storage_class = "REGIONAL"
    labels = {
              user = "trellis",
              created_by = "terraform"
    }
}

resource "google_storage_bucket_object" "trellis-readme" {
    name    = "README.txt"
    bucket  = google_storage_bucket.trellis.name
    content = <<EOT
This bucket contains configuration objects & miscellaneous other 
resources used for running Trellis.

This bucket was automatically created by Trellis Terraforming.
EOT
}
