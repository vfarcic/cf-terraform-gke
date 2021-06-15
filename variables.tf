variable "region" {
  type    = string
  default = "us-east1"
}

variable "project_id" {
  type    = string
  default = "doc-20210614224523"
}

variable "cluster_name" {
  type    = string
  default = "devops-catalog"
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "preemptible" {
  type    = bool
  default = true
}

variable "billing_account_id" {
  type    = string
  default = ""
}

variable "k8s_version" {
  type    = string
  default = "1.20.6-gke.1000"
}

variable "destroy" {
  type    = bool
  default = true
}
