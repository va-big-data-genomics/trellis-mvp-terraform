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

    # Need public IP to get Python packages
    no_public_ip = false
}

// Create startup script for AI notebook
resource "google_storage_bucket_object" "analysis-post-startup-script" {
  name   = "analysis-notebooks/notebook-post-startup-script.sh"
  bucket = google_storage_bucket.trellis.name
  content = <<EOT
#! /bin/bash

# Copy notebooks & bash scripts from GCS to instance
mkdir /home/jupyter/cronjobs
mkdir /home/jupyter/cronjobs/logs
mkdir /home/jupyter/notebooks
gsutil cp -r gs://${google_storage_bucket.trellis.name}/analysis-notebooks/cron-scripts/* /home/jupyter/cronjobs/

# Set Trellis bucket as environment variable so it can be used by the bash scripts that run the notebooks
echo TRELLIS_BUCKET=${google_storage_bucket.trellis.name} >> /home/jupyter/.bashrc
echo SAMPLE_NOTEBOOK=${var.analysis-nb-samples}
echo JOB_NOTEBOOK=${var.analysis-nb-jobs}
echo QC_NOTEBOOK=${var.analysis-nb-qc}
echo PATH=/usr/bin:/bin:/usr/local/bin:/opt/conda/bin >> /home/jupyter/.bashrc

# Allow execution of cronjob scripts
chmod 777 /home/jupyter/cronjobs/*
chmod 777 /home/jupyter/notebooks/*

chown jupyter:jupyter /home/jupyter/.bashrc
chown -R jupyter:jupyter /home/jupyter

# Add notebook cron jobs to crontab
crontab -u jupyter /home/jupyter/cronjobs/notebook-crons
EOT
}

/*
|--------------------------------------------------------------------------
| Cloud Build Triggers
|--------------------------------------------------------------------------
|
| Copy AI notebook source from GitHub to Google Cloud Storage
|
*/

// Create build trigger for copying ipynb resources from GitHub to GCS
resource "google_cloudbuild_trigger" "ai-notebooks-source" {
    provider    = google-beta
    name        = "gcs-notebook-source"
    
    github {
        owner = var.trellis-analysis-owner
        name  = var.trellis-analysis-repo
        push  {
            branch = var.github-branch-pattern
        }
    }
    
    included_files = ["cloudbuild.yaml", "notebooks/*"]

    filename = "cloudbuild.yaml"

    substitutions = {
        _TRELLIS_BUCKET = google_storage_bucket.trellis.name
    }
}

/*
|--------------------------------------------------------------------------
| Cloud Storage Objects
|--------------------------------------------------------------------------
|
| Deploy logging sinks
|
*/

// Cron-activated script to run sample-based analysis notebook
resource "google_storage_bucket_object" "ai-notebook-sample-cron-script" {
  name   = "analysis-notebooks/cron-scripts/run-sample-based-analysis.sh"
  bucket = google_storage_bucket.trellis.name
  content = <<EOT
#!/bin/bash

source /home/jupyter/.bashrc

gsutil cp gs://${google_storage_bucket.trellis.name}/analysis-notebooks/source/notebooks/${var.analysis-nb-samples} /home/jupyter/notebooks/

papermill \
    /home/jupyter/notebooks/${var.analysis-nb-samples} \
    gs://${google_storage_bucket.trellis.name}/analysis-notebooks/completed/${var.analysis-nb-samples} \
    -p bucket_info ${google_storage_bucket.trellis.name} \
    -p sample_limit 24 \
    -p credential_info trellis-config.yaml
EOT
}

// Cron-activated script to run job-based analysis notebook
resource "google_storage_bucket_object" "ai-notebook-jobs-cron-script" {
  name   = "analysis-notebooks/cron-scripts/run-job-based-analysis.sh"
  bucket = google_storage_bucket.trellis.name
  content = <<EOT
#!/bin/bash

source /home/jupyter/.bashrc

gsutil cp gs://${google_storage_bucket.trellis.name}/analysis-notebooks/source/notebooks/${var.analysis-nb-jobs} /home/jupyter/notebooks/

papermill \
    /home/jupyter/notebooks/${var.analysis-nb-jobs} \
    gs://${google_storage_bucket.trellis.name}/analysis-notebooks/completed/${var.analysis-nb-jobs} \
    -p bucket_info ${google_storage_bucket.trellis.name} \
    -p credential_info trellis-config.yaml
EOT
}

// Cron-activated script to run QC-based analysis notebook
resource "google_storage_bucket_object" "ai-notebook-qc-cron-script" {
  name   = "analysis-notebooks/cron-scripts/run-qc-analysis.sh"
  bucket = google_storage_bucket.trellis.name
  content = <<EOT
#!/bin/bash

source /home/jupyter/.bashrc

gsutil cp gs://${google_storage_bucket.trellis.name}/analysis-notebooks/source/notebooks/${var.analysis-nb-qc} /home/jupyter/notebooks/

papermill \
    /home/jupyter/notebooks/${var.analysis-nb-qc} \
    gs://${google_storage_bucket.trellis.name}/analysis-notebooks/completed/${var.analysis-nb-qc} \
    -p bucket_info ${google_storage_bucket.trellis.name} \
    -p credential_info trellis-config.yaml
EOT
}

// Crontab to schedule analysis notebook runs
resource "google_storage_bucket_object" "ai-notebook-crontab" {
  name   = "analysis-notebooks/cron-scripts/notebook-crons"
  bucket = google_storage_bucket.trellis.name
  content = <<EOT
*/3 * * * * /home/jupyter/cronjobs/run-sample-based-analysis.sh > /home/jupyter/cronjobs/logs/sample.log 2>&1
50 12,0 * * * /home/jupyter/cronjobs/run-job-based-analysis.sh > /home/jupyter/cronjobs/logs/job.log 2>&1
00 12,0 * * * /home/jupyter/cronjobs/run-qc-analysis.sh > /home/jupyter/cronjobs/logs/qc.log 2>&1
EOT
}