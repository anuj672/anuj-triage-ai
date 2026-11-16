locals {
  apis = toset([
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "aiplatform.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "logging.googleapis.com",
  ])
}

resource "google_project_service" "apis" {
  for_each           = local.apis
  service            = each.value
  disable_on_destroy = false
}