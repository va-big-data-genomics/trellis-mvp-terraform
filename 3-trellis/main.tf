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
