# The triage robot
resource "google_service_account" "triage" {
  account_id   = "triage-runtime"
  display_name = "Triage service runtime"
}

# The ONE permission it needs: call Gemini on Vertex AI
resource "google_project_iam_member" "triage_vertex" {
  project = "anuj-triage-ai"
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.triage.email}"
}

resource "google_cloud_run_v2_service" "triage" {
  name                = "triage"
  location            = "us-central1"
  deletion_protection = false

  template {
    service_account = google_service_account.triage.email

    containers {
      image = "us-central1-docker.pkg.dev/anuj-triage-ai/triage-images/triage:v2"
    }

    scaling {
      max_instance_count = 2
    }
  }

  depends_on = [google_project_service.apis]
}