// Variables requiring user-specified values
variable "project" {
    type = string
}

variable "external-bastion-ip" {
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

variable "data-group" {
    type = string
    default = "phase3"
}

variable "neo4j-image" {
    default = "neo4j:3.5.4"
}

variable "neo4j-pagecache-size" {
    type    = string
    default = "32G"
}

variable "neo4j-heap-size" {
    type    = string
    default = "32G"
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
    default = "gatk-mvp"
}

variable "gatk-github-branch-pattern" {
    type = string
    default = "^no-address$"
}
