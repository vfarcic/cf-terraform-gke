provider "google" {
  credentials = file("account.json")
  project     = var.project_id
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket      = "doc-20200910120339"
    prefix      = "terraform/state"
    credentials = "account.json"
  }
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_project_service" "cloud" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_container_cluster" "primary" {
  count                    = var.destroy == true ? 0 : 1
  name                     = var.cluster_name
  location                 = var.region
  min_master_version       = var.k8s_version
  remove_default_node_pool = true
  initial_node_count       = 1
  depends_on = [
    google_project_service.container,
    google_project_service.cloud,
  ]
}

resource "google_container_node_pool" "primary_nodes" {
  count              = var.destroy == true ? 0 : 1
  name               = var.cluster_name
  location           = var.region
  cluster            = google_container_cluster.primary[0].name
  version            = var.k8s_version
  initial_node_count = var.min_node_count
  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  autoscaling { 
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_upgrade = false
  }
  timeouts {
    create = "15m"
    update = "1h"
  }
}
