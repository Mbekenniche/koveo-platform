terraform {
  backend "gcs" {
    bucket  = "terraform-koveo"
    prefix = "bootstrap"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "koveo-bootstrap-bekenniche"
  region  = "europe-west1"
  impersonate_service_account = "terraform-runner@koveo-bootstrap-bekenniche.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "terraform-koveo" {
 name          = "terraform-koveo"
 location = "europe-west1"
 labels = {
   "key" = "test"
 }
 lifecycle_rule {
   action {
     type = "Delete"
   }
   condition {
     num_newer_versions                      = 20
     with_state                              = "ARCHIVED"
   }
 }
 lifecycle_rule {
   action {
     type = "Delete"
   }
   condition {
     days_since_noncurrent_time              = 7
     with_state                              = "ANY"
   }
 }

 versioning {
   enabled = true
 }
}
