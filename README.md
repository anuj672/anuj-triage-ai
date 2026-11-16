# gcp-ai-triage

Automatic, AI-powered incident triage on Google Cloud. When a service starts throwing errors, this platform catches them, asks Gemini on Vertex AI to diagnose the likely root cause and severity, and opens a GitHub issue with a suggested fix. No one has to go digging through logs first.

## How it works

1. Services running on Cloud Run write logs to **Cloud Logging**.
2. A **log sink** filters for entries with severity ERROR or higher and forwards them to a **Pub/Sub** topic.
3. Pub/Sub pushes each error to the **triage service** (FastAPI on Cloud Run), authenticated with OIDC.
4. The triage service sends the error to **Gemini on Vertex AI**, which returns a structured JSON diagnosis: root cause, severity, suggested fix.
5. Duplicate errors are grouped using **Firestore**, so one incident opens one issue, not fifty.
6. A **GitHub issue** is opened with the diagnosis. The GitHub token is stored in **Secret Manager**.

A deliberately breakable **victim service** is included to generate real errors for demos.

> **Note:** The victim service is a minimal FastAPI app for demos only. Its `/fail` endpoint writes a structured ERROR log, which Cloud Run sends to Cloud Logging, so the pipeline can be tested end to end. It is not meant as a production service.

## Tech stack

| Area | Tools |
| --- | --- |
| Infrastructure as code | Terraform, GCS remote state |
| Compute | Cloud Run |
| Build | Cloud Build, Artifact Registry |
| Messaging | Cloud Logging sinks, Pub/Sub, dead-letter topics |
| AI | Vertex AI, Gemini, google-genai SDK |
| Data and secrets | Firestore, Secret Manager |
| CI/CD | GitHub Actions, Workload Identity Federation |
| Language | Python, FastAPI |

## Repository layout

```
terraform/
bootstrap/ one-time setup: state bucket and the Terraform service account
modules/ reusable building blocks
environments/dev/ the dev environment
services/
triage/ the AI triage service
victim/ a service that fails on purpose
docs/ design notes and diagrams
```

## Security design

- **No service account keys.** Terraform runs by impersonating a dedicated service account with short-lived tokens. CI will use Workload Identity Federation.
- **Least privilege.** Each component has its own service account with only the roles it needs, scoped to the smallest resource possible (one bucket, one repository). IAM is managed additively with `google_project_iam_member`.
- **Dedicated build identity.** Cloud Build runs as its own service account instead of the Compute Engine default account.
- **Locked-down state.** The Terraform state bucket has versioning, uniform bucket-level access, enforced public access prevention, and `prevent_destroy`.
- **Private triage endpoint.** Only Pub/Sub, using an OIDC token, can invoke the triage service.

## Getting started

Prerequisites: a GCP project with billing enabled, the gcloud CLI, Terraform 1.6 or later.

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project <PROJECT_ID>

# one-time bootstrap: state bucket and Terraform service account (runs as you)
cd terraform/bootstrap
terraform init && terraform apply

# the dev environment (runs as the Terraform service account)
cd ../environments/dev
terraform init && terraform apply

# build the victim image
cd ../../../services/victim
gcloud builds submit --config cloudbuild.yaml .
```

## Roadmap

- [x] Remote state, Terraform service account with impersonation
- [x] Event pipeline: log sink to Pub/Sub, tested end to end
- [x] Artifact Registry and a least-privilege Cloud Build service account
- [x] Victim service image built with Cloud Build
- [ ] Deploy the victim service to Cloud Run
- [ ] Triage service with Gemini structured output
- [ ] Push subscription with OIDC auth and a dead-letter topic
- [ ] Deduplication and GitHub issue creation
- [ ] CI/CD with GitHub Actions
- [ ] Monitoring, alerting, and a dashboard for the platform itself
- [ ] Demo video
