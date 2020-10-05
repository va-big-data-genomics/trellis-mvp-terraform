/*
|------------------------------------------------------------------------
| AI (Jupyter) Notebooks
|------------------------------------------------------------------------
|
| Notebooks are used to analyze Neo4j data to assess the status of 
| global Trelllis operations & generate summary metrics.
|
*/

// Create AI notebook instance to run Jupyter analysis notebooks
resource "google_notebooks_instance" "trellis-mvp-phase3-analysis" {
    provider = google-beta
    name = "trellis-mvp-phase3-analysis"
    location = "us-west1-b"
    machine_type = "n1-standard-2"

    vm_image {
        project      = "deeplearning-platform-release"
        image_family = "tf-latest-cpu"
    }

    metadata = {
        terraform = "true"
    }

    post_startup_script = "gs://${google_storage_bucket_object.analysis-post-startup-script.bucket}/${google_storage_bucket_object.analysis-post-startup-script.output_name}"

    network = google_compute_network.trellis-vpc-network.self_link
    subnet  = google_compute_subnetwork.trellis-subnet.self_link

    no_public_ip = true
}

// Create startup script for AI notebook
resource "google_storage_bucket_object" "analysis-post-startup-script" {
  name   = "analysis-notebooks/notebook-post-startup-script.sh"
  bucket = google_storage_bucket.trellis.name
  content = <<EOT
#! /bin/bash

# Copy notebook bash scripts from GCS to instance
mkdir /home/jupyter/cronjobs
gsutil cp -r gs://${google_storage_bucket.trellis.name}/analysis-notebooks/source/cronjobs/* /home/jupyter/cronjobs/

# Set Trellis bucket as environment variable so it can be used by the bash scripts that run the notebooks
echo TRELLIS_BUCKET=${google_storage_bucket.trellis.name} > ~/.bashrc

# Add notebook cron jobs to crontab
crontab /home/jupyter/cronjobs/notebook-crons
EOT
}

// Create build trigger for copying ipynb resources from GitHub to GCS
resource "google_cloudbuild_trigger" "notebook-source" {
    provider    = google-beta
    name        = "gcs-notebook-source"
    
    github {
        owner = var.trellis-analysis-owner
        name  = var.trellis-analysis-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["cloudbuild.yaml", "cronjobs/*", "notebooks/*"]

    filename = "cloudbuild.yaml"

    substitutions = {
        _TRELLIS_BUCKET = google_storage_bucket.trellis.name
    }
}