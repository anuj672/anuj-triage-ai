import {
  to = google_pubsub_subscription.debug
  id = "projects/anuj-triage-ai/subscriptions/debug-sub"
}

resource "google_pubsub_subscription" "debug" {
  name  = "debug-sub"
  topic = google_pubsub_topic.errors.id

  message_retention_duration = "600s"

  expiration_policy {
    ttl = "86400s"
  }
}