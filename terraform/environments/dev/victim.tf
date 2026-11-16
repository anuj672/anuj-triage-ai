resource "google_service_account" "victim" {
  account_id   = "victim-runtime"
  display_name = "Victim app runtime"
}

resource "google_cloud_run_v2_service" "victim" {
  name                = "victim"
  location            = "us-central1"
  deletion_protection = false

  template {
    service_account = google_service_account.victim.email

    containers {
      image = "us-central1-docker.pkg.dev/anuj-triage-ai/triage-images/victim:v1"
    }

    scaling {
      max_instance_count = 1
    }
  }

  depends_on = [google_project_service.apis]
}