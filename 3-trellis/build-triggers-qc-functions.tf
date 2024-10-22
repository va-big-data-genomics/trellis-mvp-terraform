/*
|-----------------------------------------------------------------------
| Cloud Build Triggers
|-----------------------------------------------------------------------
|
| Deploy cloud functions
|
*/

resource "google_cloudbuild_trigger" "launch-bam-fastqc" {
    name        = "gcf-launch-bam-fastqc"
    provider    = google-beta
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["functions/launch-bam-fastqc/*"]

    filename = "functions/launch-bam-fastqc/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB   = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET = google_storage_bucket.trellis.name
        _TRIGGER_TOPIC      = google_pubsub_topic.launch-bam-fastqc.name
        _ENVIRONMENT        = "google-cloud"
    }

}

resource "google_cloudbuild_trigger" "launch-flagstat" {
    name        = "gcf-launch-flagstat"
    provider    = google-beta
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["functions/launch-flagstat/*"]

    filename = "functions/launch-flagstat/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB   = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET = google_storage_bucket.trellis.name
        _TRIGGER_TOPIC      = google_pubsub_topic.launch-flagstat.name
        _ENVIRONMENT        = "google-cloud"
    }

}

resource "google_cloudbuild_trigger" "launch-vcfstats" {
    name        = "gcf-launch-vcfstats"
    provider    = google-beta
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["functions/launch-vcfstats/*"]

    filename = "functions/launch-vcfstats/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB   = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET = google_storage_bucket.trellis.name
        _TRIGGER_TOPIC      = google_pubsub_topic.launch-vcfstats.name
        _ENVIRONMENT        = "google-cloud"
    }

}

resource "google_cloudbuild_trigger" "launch-text-to-table" {
    name        = "gcf-launch-text-to-table"
    provider    = google-beta
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["functions/launch-text-to-table/*"]

    filename = "functions/launch-text-to-table/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB   = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET = google_storage_bucket.trellis.name
        _TRIGGER_TOPIC      = google_pubsub_topic.launch-text-to-table.name
        _ENVIRONMENT        = "google-cloud"
    }

}

/* Replaced by Postgres database
resource "google_cloudbuild_trigger" "bigquery-import-csv" {
    name        = "gcf-bigquery-import-csv"
    provider    = google-beta
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["functions/bigquery-import-csv/*"]

    filename = "functions/bigquery-import-csv/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB   = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET = google_storage_bucket.trellis.name
        _TRIGGER_TOPIC      = google_pubsub_topic.bigquery-import-csv.name
        _ENVIRONMENT        = "google-cloud"
    }

}

resource "google_cloudbuild_trigger" "bigquery-append-tsv" {
    name        = "gcf-bigquery-append-tsv"
    provider    = google-beta
    
    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["functions/bigquery-append-tsv/*"]

    filename = "functions/bigquery-append-tsv/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB   = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET = google_storage_bucket.trellis.name
        _TRIGGER_TOPIC      = google_pubsub_topic.bigquery-append-tsv.name
        _ENVIRONMENT        = "google-cloud"
    }

}
*/

resource "google_cloudbuild_trigger" "postgres-insert-data" {
    name        = "gcf-postgres-insert-data"
    provider    = google-beta

    github {
        owner = var.github-owner
        name  = var.github-repo
        push  {
            branch = var.github-branch-pattern
        }
    }

    included_files = ["functions/postgres-insert-data/*"]
    filename = "functions/postgres-insert-data/cloudbuild.yaml"

    substitutions = {
        _CREDENTIALS_BLOB   = google_storage_bucket_object.trellis-config.name
        _CREDENTIALS_BUCKET = google_storage_bucket.trellis.name
        _TRIGGER_TOPIC      = google_pubsub_topic.postgres-insert-data.name
        _ENVIRONMENT        = "google-cloud"
    }
}