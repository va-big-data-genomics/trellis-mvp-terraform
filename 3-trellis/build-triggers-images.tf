/*
|--------------------------------------------------------------------------
| Cloud Build Triggers
|--------------------------------------------------------------------------
|
| Deploy cloud functions
|
*/

resource "google_cloudbuild_trigger" "docker-images" {
    provider    = google-beta
    name        = "gcr-docker-images"
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["images/cloudbuild.yaml"]

    filename = "images/cloudbuild.yaml"
}