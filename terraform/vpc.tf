# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"

  depends_on              = [google_project_service.project] 
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = "us-central1"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# Enable APIs
resource "google_project_service" "project" {
  count                      = var.enable_apis ? length(var.activate_apis) : 0
  project                    = var.project_id
  service                    = element(var.activate_apis, count.index)
  disable_on_destroy         = false
  disable_dependent_services = true

  timeouts {
    create = "10m"
    update = "15m"
  }

}