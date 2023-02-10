# VPC
variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

# GKE cluster
variable "gke_username" {
  default     = "gke-admin"
  description = "gke username"
}

variable "gke_password" {
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "enable_apis" {
  default     = true
  description = "Enable APIs?"
}

variable "activate_apis" {
  description = "APIs to enable"
}