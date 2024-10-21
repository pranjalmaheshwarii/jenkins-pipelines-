# main.tf
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
  credentials = file("gs://bucket_2607/tf-k8-key/black-outlet-438804-p8-7ce3a755dbe1.json")  # Path to your new service account key
  project     = "black-outlet-438804-p8"
  region      = "us-central1"
}

resource "google_container_cluster" "primary" {
  name     = "my-cluster"
  location = "us-central1"

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"  # Adjust based on your needs
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# Output the cluster endpoint and credentials
output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_location" {
  value = google_container_cluster.primary.location
}
