/*
|--------------------------------------------------------------------------
| Project Configuration
|--------------------------------------------------------------------------
|
|
*/

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

/* Not sure what this is for
resource "google_project_service" "project" {
  project = var.project
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
}
*/

// Add project labels. Require to import project state first.
resource "google_project" "trellis_project" {
  name       = var.project
  project_id = var.project
  labels     = {trellis-network = "trellis", trellis-subnetwork = "trellis-us-west1"}
  lifecycle {
    ignore_changes = [name, billing_account]
  }
}
