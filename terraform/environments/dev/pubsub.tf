resource "google_pubsub_topic" "errors" {
  name = "error-events"

  depends_on = [google_project_service.apis]
}