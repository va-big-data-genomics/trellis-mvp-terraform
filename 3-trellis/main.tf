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

// Enable the Cloud Functions & Cloud Run API
resource "google_project_service" "functions" {
  project = var.project
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "run" {
  project = var.project
  service = "run.googleapis.com"
}

// Retrieve default service account
data "google_compute_default_service_account" "default" {
}

// Formulate Cloud Build Service Account
locals {
  cloudbuild_sa = replace(data.google_compute_default_service_account.default.email, "-compute@developer.gserviceaccount.com", "@cloudbuild.gserviceaccount.com")
}

// Binding roles to service account
resource "google_project_iam_binding" "functions" {
  project = var.project
  role    = "roles/cloudfunctions.developer"
  members  = [
    "serviceAccount:${local.cloudbuild_sa}"
  ]
}

resource "google_project_iam_binding" "run" {
  project = var.project
  role    = "roles/run.admin"
  members  = [
    "serviceAccount:${local.cloudbuild_sa}"
  ]
}

// Add project labels. Require to import project state first.
resource "google_project" "trellis_project" {
  name       = var.project
  project_id = var.project
  labels     = {trellis-network = "trellis", trellis-subnetwork = "trellis-us-west1"}
  lifecycle {
    ignore_changes = [name, billing_account]
  }
}
