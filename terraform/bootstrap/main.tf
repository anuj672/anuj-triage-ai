provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tfstate" {
  # Bucket names are GLOBAL across all of GCP; project ID makes it unique
  name     = "${var.project_id}-tfstate"
  location = var.region

  # Access controlled ONLY by IAM, never per-object ACLs (old-style, error-prone)
  uniform_bucket_level_access = true

  # Hard block on anything ever becoming public
  public_access_prevention = "enforced"

  # Keep every version of the state file, so a corrupted state can be rolled back
  versioning {
    enabled = true
  }

  # ...but don't keep infinite versions forever: delete old ones beyond 10
  lifecycle_rule {
    condition {
      num_newer_versions = 10
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  # Terraform itself will refuse to destroy this bucket
  lifecycle {
    prevent_destroy = true
  }
}