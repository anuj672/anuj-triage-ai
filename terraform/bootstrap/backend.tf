terraform {
  backend "gcs" {
    bucket = "anuj-triage-ai-tfstate"
    prefix = "bootstrap"
  }
}