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

resource "google_cloud_scheduler_job" "trigger-fastq-to-ubam-25" {
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
            "labels": ["PersonalisSequencing", "Marker", "Cypher", "Query"],
            "sentFrom": "cron-trigger-fastq-to-ubam-25",
            "publishTo": "${google_pubsub_topic.check-triggers.name}"
    },
    "body": {  
        "cypher": "MATCH (s:PersonalisSequencing)-[:GENERATED]->(f:Fastq) WHERE NOT (f)-[:WAS_USED_BY]->(:JobRequest:FastqToUbam) WITH DISTINCT s AS node SET node:Marker, node.labels = node.labels + 'Marker' RETURN node LIMIT 25", 
        "result-mode": "data",
        "result-structure": "list",
        "result-split": "True"
  }
}
EOT
)
    }
}

resource "google_cloud_scheduler_job" "trigger-fq2u-covid19-25" {
    region = var.app-engine-region

    name = "cron-trigger-fq2u-covid19-25"
    description = "Launch variant calling for 25 COVID19 positive samples every hour"
    schedule = "0 * * * *"
    time_zone = "America/Los_Angeles"

    pubsub_target {
        topic_name = google_pubsub_topic.db-query.id
        data = base64encode(<<EOT
{
    "header": {
        "resource": "query",
            "method": "VIEW",
            "labels": ["Sample", "COVID19", "Marker", "Cypher", "Query"],
            "sentFrom": "cron-trigger-fq2u-covid19-25",
            "publishTo": "${google_pubsub_topic.check-triggers.name}"
    },
    "body": {  
        "cypher": "MATCH (s:PersonalisSequencing:COVID19)-[:GENERATED]->(f:Fastq) WHERE s.covid19Positive=True AND NOT (f)-[:WAS_USED_BY]->(:JobRequest:FastqToUbam) WITH DISTINCT s AS node SET node:Marker, node.labels = node.labels + 'Marker' RETURN node LIMIT 25", 
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
            "labels": ["PersonalisSequencing", "Marker", "Cypher", "Query"],
            "sentFrom": "cron-trigger-fastq-to-ubam-1",
            "publishTo": "${google_pubsub_topic.check-triggers.name}"
    },
    "body": {  
        "cypher": "MATCH (s:PersonalisSequencing)-[:GENERATED]->(f:Fastq) WHERE NOT (f)-[:WAS_USED_BY]->(:JobRequest:FastqToUbam) WITH DISTINCT s AS node SET node:Marker, node.labels = node.labels + 'Marker' RETURN node LIMIT 1", 
        "result-mode": "data",
        "result-structure": "list",
        "result-split": "True"
  }
}
EOT
)
    }
}

resource "google_cloud_scheduler_job" "request-launch-view-signature-snps" {
    region = var.app-engine-region

    name = "cron-request-launch-view-signature-snps"
    description = "Launch view-gvcf-snps job to get signature SNPs from sample gVCF"
    schedule = "0 9 25 12 1"
    time_zone = "America/Los_Angeles"

    pubsub_target {
        topic_name = google_pubsub_topic.check-triggers.id
        data = base64encode(<<EOT
{
    "header": {
        "resource": "request",
        "method": "VIEW",
        "labels": ['Request', 'LaunchViewSignatureSnps'],
        "sentFrom": "cron-request-launch-view-signature-snps"
    },
    "body": {
        "results": {}
    }
}
EOT
)
    }    
}
