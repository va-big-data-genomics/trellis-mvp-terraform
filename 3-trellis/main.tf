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

resource "google_project_service" "sql" {
  project = var.project
  service = "sqladmin.googleapis.com"
}

// Formulate Cloud Build Service Account
locals {
  cloudbuild_sa =  "${google_project.trellis_project.number}@cloudbuild.gserviceaccount.com"
}

// Pub/Sub Service Account
locals {
  pubsub_sa = "service-${google_project.trellis_project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
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

// Integrating Cloud Run with Pub/Sub
resource "google_project_iam_binding" "pubsub" {
  project = var.project
  role    = "roles/iam.serviceAccountTokenCreator"
  members  = [
    "serviceAccount:${local.pubsub_sa}"
  ]
}

resource "google_service_account" "cloud-run-pubsub-invoker-sa" {
  account_id   = "cloud-run-pubsub-invoker"
  display_name = "Cloud Run Pub/Sub Invoker"
}

// Need to import trellis-check-dstat service first
//resource "google_cloud_run_service_iam_binding" "binding" {
//  location = google_cloud_run_service.check-dstat.location
//  project = google_cloud_run_service.check-dstat.project
//  service = google_cloud_run_service.check-dstat.name
//  role = "roles/run.invoker"
//  members = [
//    "serviceAccount:${google_service_account.cloud-run-pubsub-invoker-sa.email}",
//  ]
//}

// Add project labels. Require to import project state first.
// $ terraform import google_project.trellis_project {project name}
resource "google_project" "trellis-project" {
  name       = var.project
  project_id = var.project
  labels     = {
                trellis-network = "trellis",
                trellis-subnetwork = "trellis-us-west1"}
  lifecycle {
    ignore_changes = [name, billing_account]
  }
}
