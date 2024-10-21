terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5" # Adjust as needed
    }
  }

  required_version = ">= 0.12"
}

provider "google" {
  credentials = file("service-account-key.json")  # Path to your service account key
  project     = var.project_id
  region      = var.region
}

variable "project_id" {
  description = "The ID of the project in GCP"
  type        = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "The region where the cluster will be created"
  type        = string
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  initial_node_count = 1

  # Configure the private cluster settings
  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = true  # Control plane will be accessed via private IP
    master_ipv4_cidr_block = "10.8.0.0/28"  # Adjust as needed for your IP range
  }

  node_config {
    machine_type = "e2-medium"  # Adjust based on your needs
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_location" {
  value = google_container_cluster.primary.location
}
