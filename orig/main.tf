provider "google" {
  credentials = file("account.json")
  project     = var.project_id
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket      = "CHANGE_BUCKET"
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
  name               = var.cluster_name
  location           = var.region
  cluster            = google_container_cluster.primary.name
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

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig gcloud container clusters get-credentials ${var.cluster_name} --project ${var.project_id} --region ${var.region}"
  }
  depends_on = [
    google_container_cluster.primary,
  ]
}

resource "null_resource" "destroy-kubeconfig" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f $PWD/kubeconfig"
  }
}

resource "null_resource" "ingress-nginx" {
  provisioner "local-exec" {
    command = "KUBECONFIG=$PWD/kubeconfig kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml"
  }
  depends_on = [
    null_resource.kubeconfig,
  ]
}
