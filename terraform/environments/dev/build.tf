resource "google_service_account" "cloudbuild" {
account_id = "cloudbuild-runner"
display_name = "Cloud Build runner"
}

resource "google_storage_bucket_iam_member" "build_source" {
bucket = "anuj-triage-ai_cloudbuild"
role = "roles/storage.objectViewer"
member = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_artifact_registry_repository_iam_member" "build_push" {
location = google_artifact_registry_repository.images.location
repository = google_artifact_registry_repository.images.name
role = "roles/artifactregistry.writer"
member = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_project_iam_member" "build_logs" {
  project = "anuj-triage-ai"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}