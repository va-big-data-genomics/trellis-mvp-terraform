/*
|--------------------------------------------------------------------------
| Cloud Scheduler Jobs
|--------------------------------------------------------------------------
|
| Cloud Scheduler jobs (i.e CRON jobs) are used to send requests
| to Trellis. These CRON jobs are used to import object metadata
| to the database & periodically launch batch jobs.
|
*/

resource "google_cloud_scheduler_job" "cron-import-data-from-personalis" {
    region = var.app-engine-region

    name = "cron-import-data-from-personalis"
    description = "Import from-personalis blob metadata to Neo4j"
    schedule = "0 0 25 12 0"
    time_zone = "America/Los_Angeles"

    pubsub_target {
        topic_name = google_pubsub_topic.list-bucket-page.id
        data = base64encode(<<EOT
{
    "resource": "bucket", 
    "gcp-metadata": {
        "name": "${var.project}-from-personalis",
        "prefix": "va_mvp_phase2"
    }
}
EOT
)
    }
}

resource "google_cloud_scheduler_job" "trigger-fastq-to-ubam-50" {
    region = var.app-engine-region

    name = "cron-trigger-fastq-to-ubam-25"
    description = "Launch variant calling for 25 samples every hour"
    schedule = "0 * * * *"
    time_zone = "America/Los_Angeles"

    pubsub_target {
        topic_name = google_pubsub_topic.db-query.id
        data = base64encode(<<EOT
{
    "header": {
        "resource": "query",
            "method": "VIEW",
            "labels": ["Sample", "Marker", "Cypher", "Query"],
            "sentFrom": "cron-trigger-fastq-to-ubam-25",
            "publishTo": "${google_pubsub_topic.check-triggers.name}"
    },
    "body": {  
        "cypher": "MATCH (s:Sample)-[:HAS]->(f:Fastq) WHERE NOT (f)-[:INPUT_TO]->(:JobRequest:FastqToUbam) WITH DISTINCT s AS node SET node:Marker, node.labels = node.labels + 'Marker' RETURN node LIMIT 25", 
        "result-mode": "data",
        "result-structure": "list",
        "result-split": "True"
  }
}
EOT
)
    }
}

resource "google_cloud_scheduler_job" "trigger-relaunch-failed-gatk" {
    region = var.app-engine-region

    name = "cron-trigger-relaunch-failed-gatk"
    description = "Launch GATK $5 for samples where job failed initially"
    schedule = "0 9 25 12 1"
    time_zone = "America/Los_Angeles"

    pubsub_target {
        topic_name = google_pubsub_topic.check-triggers.id
        data = base64encode(<<EOT
{
    "header": {
        "resource": "request",
        "method": "VIEW",
        "labels": ["Request", "LaunchFailedGatk5Dollar", "All"],
        "sentFrom": "cron-trigger-relaunch-failed-gatk"
    },
    "body": {
        "results": {}
    }
}
EOT
)
    }
}

resource "google_cloud_scheduler_job" "trigger-postgres-import" {
    region = var.app-engine-region

    name = "cron-trigger-request-postgres-import"
    description = "Import QC data into Postgres database"
    schedule = "0 9 25 12 1"
    time_zone = "America/Los_Angeles"

    pubsub_target {
        topic_name = google_pubsub_topic.check-triggers.id
        data = base64encode(<<EOT
{
    "header": {
        "resource": "request",
        "method": "VIEW",
        "labels": ["Request", "PostgresInsertTextToTable", "PostgresInsertContamination", "All"],
        "sentFrom": "cron-trigger-request-postgres-import"
    },
    "body": {
        "results": {}
    }
}
EOT
)
    }
}

resource "google_cloud_scheduler_job" "trigger-fastq-to-ubam-1" {
    region = var.app-engine-region

    name = "cron-trigger-fastq-to-ubam-1"
    description = "Launch variant calling for 1 sample"
    schedule = "0 9 25 12 1"
    time_zone = "America/Los_Angeles"

    pubsub_target {
        topic_name = google_pubsub_topic.db-query.id
        data = base64encode(<<EOT
{
    "header": {
        "resource": "query",
            "method": "VIEW",
            "labels": ["Sample", "Marker", "Cypher", "Query"],
            "sentFrom": "cron-trigger-fastq-to-ubam-1",
            "publishTo": "${google_pubsub_topic.check-triggers.name}"
    },
    "body": {  
        "cypher": "MATCH (s:Sample)-[:HAS]->(f:Fastq) WHERE NOT (f)-[:INPUT_TO]->(:JobRequest:FastqToUbam) WITH DISTINCT s AS node SET node:Marker, node.labels = node.labels + 'Marker' RETURN node LIMIT 1", 
        "result-mode": "data",
        "result-structure": "list",
        "result-split": "True"
  }
}
EOT
)
    }
}
