resource "google_service_account" "terraform" {
account_id = "terraform-deployer"
display_name = "Terraform deployer"
}

resource "google_project_service" "iamcredentials" {
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account_iam_member" "me_can_impersonate" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:canujnaresh@gmail.com"
}

resource "google_storage_bucket_iam_member" "terraform_state" {
bucket = google_storage_bucket.tfstate.name
role = "roles/storage.objectAdmin"
member = "serviceAccount:${google_service_account.terraform.email}"
}

locals {
  terraform_sa_roles = toset([
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/pubsub.admin",
    "roles/run.admin",
    "roles/logging.configWriter",
    "roles/artifactregistry.admin",
  ])
}

resource "google_project_iam_member" "terraform_sa" {
  for_each = local.terraform_sa_roles
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_storage_bucket_iam_member" "terraform_manage_build_bucket" {
  bucket = "anuj-triage-ai_cloudbuild"
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}