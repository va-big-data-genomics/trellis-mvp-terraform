/*
|--------------------------------------------------------------------------
| Cloud Build Triggers
|--------------------------------------------------------------------------
|
| Deploy cloud functions for enabling request-driven database import.
|
*/

resource "google_cloudbuild_trigger" "launch-view-gvcf-snps" {
    provider    = google-beta
    name        = "gcf-launch-view-gvcf-snps"
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = [
        "functions/launch-view-gvcf-snps/*",
    ]

    filename = "functions/launch-view-gvcf-snps/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB       = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET     = google_storage_bucket.trellis.name
        _ENVIRONMENT            = "google-cloud"
        _TRIGGER_TOPIC          = google_pubsub_topic.launch-gatk-5-dollar.name
    }
}


