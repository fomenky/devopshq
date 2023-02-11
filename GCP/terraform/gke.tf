# GKE cluster
resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = "${var.project_id}-gke"
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  addons_config {
    config_connector_config {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  provider = google-beta

}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name               = google_container_cluster.primary.name
  location           = var.region
  cluster            = google_container_cluster.primary.name
  initial_node_count = var.gke_num_nodes

  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = 2

    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = 4
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Anthos Config Management
resource "google_gke_hub_membership" "membership" {
  project = var.project_id
  membership_id = "gke-membership"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.primary.id}"
    }
  }
  provider = google-beta
}

resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  name = "configmanagement"
  project = var.project_id
  location = "global"
  provider = google-beta
}

resource "google_gke_hub_feature_membership" "feature_member" {
  provider = google-beta

  project = var.project_id
  location = "global"
  feature = google_gke_hub_feature.configmanagement_acm_feature.name
  membership = google_gke_hub_membership.membership.membership_id
  configmanagement {
    version = "1.14.1"
    config_sync {
      git {
        sync_repo   = "https://github.com/fomenky/devopshq.git"
        sync_branch = "main"
        policy_dir  = "GCP/kcc"
        secret_type = "none"
      }
    }
  }
  policy_controller {
    enabled                    = true
    template_library_installed = true
    referential_rules_enabled  = true
  }
}

# create a GCP service account that will be used to make changes to K8s resources and bind it to Kubernetes Service Account #
module "wi" {
 source               = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "~> 16.0.1"
  gcp_sa_name         = "cnrmsa"
  cluster_name        = google_container_cluster.primary.name
  name                = "cnrm-controller-manager"
  location            = var.region
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  namespace           = "cnrm-system"
  project_id          = var.project_id
  roles               = ["roles/owner"]
}


# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

