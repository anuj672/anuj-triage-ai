provider "google" {
  project                     = "anuj-triage-ai"
  region                      = "us-central1"
  impersonate_service_account = "terraform-deployer@anuj-triage-ai.iam.gserviceaccount.com"
}