/*
|--------------------------------------------------------------------------
| Project Configuration
|--------------------------------------------------------------------------
|
| Deploy a Neo4j graph database instance to act as the global metadata
| store for Trellis.
|
*/

module "gce-container" {
  source = "./google-container-vm"

  container = {
    image = "gcr.io/${var.project}/${var.neo4j-image}"

    env = [
      {
        "name"  = "NEO4J_dbms_memory_pagecache_size"
        "value" = var.neo4j-pagecache-size
      },
      {
        "name"  = "NEO4J_dbms_memory_heap_initial__size"
        "value" = var.neo4j-heap-size
      },
      {
        "name"  = "NEO4J_dbms_memory_heap_max__size"
        "value" = var.neo4j-heap-size
      },
    ]

    # Declare volumes to be mounted
    # This is similar to how Docker volumes are mounted
    volumeMounts = [
      {
        mountPath = "/data"
        name      = "data-disk-0"
        readOnly  = false
      },
    ]
  }

  # Declare the volumes
  volumes = [
    {
      name = "data-disk-0"

      gcePersistentDisk = {
        pdName = "data-disk-0"
        fsType = "ext4"
      }
    },
  ]

  restart_policy = "Always"
}

// Create Neo4j instance
resource "google_compute_instance" "neo4j-database" {
    name = "trellis-neo4j-db"
    machine_type = "custom-12-71680"
    
    allow_stopping_for_update = true

    boot_disk {
        initialize_params {
            image = module.gce-container.source_image
        }
    }

    // Created by perma-resources module
    attached_disk {
        source      = "disk-trellis-neo4j-data"
        device_name = "data-disk-0"
        mode        = "READ_WRITE"
    }
    
    network_interface {
        network = google_compute_network.trellis-vpc-network.self_link
        subnetwork = google_compute_subnetwork.trellis-subnet.self_link
        access_config {}
    }

    metadata = {
        gce-container-declaration = module.gce-container.metadata_value
    }

    labels = {
        container-vm = module.gce-container.vm_container_label
    }

    tags = ["neo4j","https-server"]

    service_account {
        scopes = ["cloud-platform"]
    }
}

// Configure Cloud SQL PostgreSQL private IP
resource "google_compute_global_address" "private_ip_postgresql" {
  provider = google-beta

  name          = "private-ip-postgresql"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.trellis-vpc-network.self_link
}

resource "google_service_networking_connection" "private-vpc-postgresql" {
  provider = google-beta

  network                 = google_compute_network.trellis-vpc-network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_postgresql.name]
}

// Create Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "postgresql-database" {
  name             = "trellis-qc-db"
  database_version = "POSTGRES_11"
  region           = "us-west1"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.trellis-vpc-network.self_link
    }
  }
}
