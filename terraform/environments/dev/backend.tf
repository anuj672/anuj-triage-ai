terraform {
  backend "gcs" {
    bucket                      = "anuj-triage-ai-tfstate"
    prefix                      = "environments/dev"
    impersonate_service_account = "terraform-deployer@anuj-triage-ai.iam.gserviceaccount.com"
  }
} 