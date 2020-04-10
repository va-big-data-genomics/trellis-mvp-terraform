resource "google_compute_resource_policy" "daily_snapshot" {
  name   = "dailysnapshot"
  region = var.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
  }
}
