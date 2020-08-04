// Variables requiring user-specified values
variable "project" {
    type = string
}

variable "external-bastion-ip" {
    type = string
}

variable "db-user" {
    type = string
}

variable "db-passphrase" {
    type = string
}

// Variables with default values
variable "region" {
    type = string
    default = "us-west1"
}

variable "zone" {
    type = string
    default = "us-west1-b"
}

variable "app-engine-region" {
    type = string
    default = "us-west2"
}

variable "data-group" {
    type = string
    default = "phase3"
}

// Neo4j metadata store variables
variable "neo4j-image" {
    default = "neo4j:3.5.4"
}

variable "neo4j-pagecache-size" {
    type    = string
    default = "64G"
}

variable "neo4j-heap-size" {
    type    = string
    default = "64G"
}

// PostgreSQL QC database variables
variable "qc-db-user" {
    type    = string
    default = "postgres"
}

variable "qc-db-pass" {
    type = string
}

variable "github-owner" {
    type = string
    description = "Owner of the Trellis GitHub repo."
    default = "StanfordBioinformatics"
}

variable "github-repo" {
    type = string
    description = "Name of the Trellis GitHub repo."
    default = "trellis-mvp-functions"
}

variable "github-branch-pattern" {
    type = string
    default = "master"
}

variable "gatk-github-owner" {
    type        = string
    description = "Owner of the repo with GATK pipeline config objects."
    default     = "StanfordBioinformatics"
}

variable "gatk-github-repo" {
    type = string
    default = "trellis-mvp-gatk"
}

variable "gatk-github-branch-pattern" {
    type = string
    default = "^no-address$"
}
