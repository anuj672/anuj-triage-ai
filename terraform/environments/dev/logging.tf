resource "google_logging_project_sink" "errors" {
  name        = "error-sink"
  destination = "pubsub.googleapis.com/${google_pubsub_topic.errors.id}"
  filter      = "severity>=ERROR"

  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "sink_can_publish" {
  topic  = google_pubsub_topic.errors.name
  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.errors.writer_identity
}