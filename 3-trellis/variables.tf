// Variables requiring user-specified values
variable "project" {
    type = string
}

variable "external-bastion-ip" {
   type = string
   default = ""
}

variable "db-user" {
    type = string
}

variable "db-passphrase" {
    type = string
}

variable "neo4j-attached-disk" {
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
    description = "Owner of the Trellis GitHub repository."
    default = "StanfordBioinformatics"
}

variable "github-repo" {
    type = string
    description = "Name of the Trellis GitHub repository."
    default = "trellis-mvp-functions"
}

variable "trellis-analysis-owner" {
    type = string
    description = "Owner of the Trellis analysis repository."
    default = "StanfordBioinformatics"
}

variable "trellis-analysis-repo" {
    type = string
    description = "Name of Trellis analysis repo containing Jupyter notebooks to run meta analyses."
    default = "trellis-mvp-analysis"
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

variable "topic_labels" {
    type        = map(string)
    default     = {"user":"trellis", "created_by":"terraform"}
    description = "A set of key/value label pairs to assign to the pubsub topic."
}

variable "gatk-mvp-hash" {
    type = string
    description = "Hash (7 char) of git commit of gatk-mvp GitHub repo to use for germline variant calling."
}
