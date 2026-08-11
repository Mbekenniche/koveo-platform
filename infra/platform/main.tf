terraform {
  backend "gcs" {
    bucket  = "terraform-koveo"
    prefix = "platform"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "koveo-fret-prd"
  region  = "europe-west1"
  impersonate_service_account = "terraform-runner@koveo-bootstrap-bekenniche.iam.gserviceaccount.com"
}

resource "google_compute_network" "vpc_production" {
    name = "vpc-production"
    auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "sub_administration" {
  name          = "sub-administration"
  region  = "europe-west1"
  ip_cidr_range = "10.100.16.0/24"
  network       = google_compute_network.vpc_production.id
}
resource "google_compute_subnetwork" "sub_data" {
  name          = "sub-data"
  region  = "europe-west1"
  ip_cidr_range = "10.100.32.0/24"
  network       = google_compute_network.vpc_production.id
}
resource "google_compute_subnetwork" "sub_gpu" {
  name          = "sub-gpu"
  region  = "europe-west1"
  ip_cidr_range = "10.100.48.0/24"
  network       = google_compute_network.vpc_production.id
}
resource "google_compute_subnetwork" "sub_ci" {
  name          = "sub-ci"
  region  = "europe-west1"
  ip_cidr_range = "10.100.64.0/24"
  network       = google_compute_network.vpc_production.id
}

resource "google_compute_subnetwork" "sub_node" {
  name          = "sub-node"
  region  = "europe-west1"
  ip_cidr_range = "10.100.0.0/20"
  network       = google_compute_network.vpc_production.id
  secondary_ip_range {
    range_name    = "secondary-range-pods"
    ip_cidr_range = "10.101.0.0/16"
  }
  secondary_ip_range {
    range_name    = "secondary-range-services"
    ip_cidr_range = "10.102.0.0/16"
  }
}

resource "google_compute_network_firewall_policy" "policy_gcp_prod" {
  name = "policy-gcp-prod"
}

resource "google_compute_network_firewall_policy_rule" "deny_all" {
  firewall_policy = google_compute_network_firewall_policy.policy_gcp_prod.name
  priority        = 20000
  action          = "deny"
  direction       = "INGRESS"

  match {
    src_ip_ranges = ["0.0.0.0/0"]
    layer4_configs {
      ip_protocol = "all"
    }
  }
}
/* resource "google_compute_network_firewall_policy_rule" "allow_egress_intern_gpu" {
  firewall_policy = google_compute_network_firewall_policy.policy_gcp_prod.name
  priority        = 2000
  action          = "allow"
  direction       = "EGRESS"

  match {
    src_ip_ranges = [ google_compute_subnetwork.sub_gpu.ip_cidr_range ]
    dest_ip_ranges = [ "10.100.0.0/16", "10.101.0.0/20","10.102.0.0/20"]
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "deny_egress_gpu" {
  firewall_policy = google_compute_network_firewall_policy.policy_gcp_prod.name
  priority        = 3000
  action          = "deny"
  direction       = "EGRESS"

  match {

    src_ip_ranges = [ google_compute_subnetwork.sub_gpu.ip_cidr_range ]
    dest_ip_ranges = [ "0.0.0.0/0" ]
    layer4_configs {
      ip_protocol = "all"
    }
  }
} */

resource "google_compute_network_firewall_policy_association" "assoc" {
  name              = "assoc-vpc-prod"
  firewall_policy   = google_compute_network_firewall_policy.policy_gcp_prod.name
  attachment_target = google_compute_network.vpc_production.id

}
