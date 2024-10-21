terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"  # Adjust the version as needed
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

  # Enable private nodes and configure the master authorized networks for Jenkins
  private_cluster_config {
    enable_private_endpoint = false  # Disable private endpoint
    enable_private_nodes    = true   # Private nodes enabled
    master_ipv4_cidr_block  = "10.0.0.0/28"  # IP block for master's private IP range
  }

  # Allow Jenkins server access to the Kubernetes master endpoint
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "35.192.76.212/32"  # Jenkins public IP address
      display_name = "Jenkins Server"
    }
  }

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"  # Adjust based on your needs
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  network    = "default"  # Default VPC network; update if using a custom VPC
  subnetwork = "default"  # Default subnet; update if using a custom subnet
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

output "jump_server_ip" {
  value = "35.192.76.212"  # Output the Jenkins server IP
}
