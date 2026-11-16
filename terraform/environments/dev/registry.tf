resource "google_artifact_registry_repository" "images" {
  location      = "us-central1"
  repository_id = "triage-images"
  format        = "DOCKER"

  depends_on = [google_project_service.apis]
}