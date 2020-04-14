resource "google_bigquery_dataset" "mvp" {
    dataset_id  = "trellis_mvp_${var.data-group}"
    location    = "US"

    labels = {
        user = "trellis"
        cohort = "mvp"
        dataset = var.data-group
    }
}
