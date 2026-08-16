resource "google_artifact_registry_repository" "koveofret" {
  location      = "europe-west1"
  repository_id = "koveofret-prd"
  description   = "Repository of Koveofret's images"
  format        = "DOCKER"
  cleanup_policies {
    id     = "delete-older-seven-days"
    action = "DELETE"
    condition {
      tag_state = "UNTAGGED"
      older_than   = "604800s"
    }
  }
  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count            = 5
    }
  }

  labels = {
    "env" = "prd",
    "lot" = "l5",
    "etape" = "j4",
    "owner" = "mbekenniche",
    "ephemeral" = "false",
    "cost-center" = "koveo-fret"
  }
}
