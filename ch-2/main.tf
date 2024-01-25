# Create Service Account and assign permissions to deploy
resource "google_service_account" "cloudbuild_service_account" {
  account_id = "cloudbuild-sa"
}

resource "google_project_iam_member" "role_binding" {
  for_each = var.iam_roles
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

# Create Cloud Source repository
resource "google_sourcerepo_repository" "source-repo" {
  name    = "GCP_CloudBuild_Exercises"
  project = var.project_id
}

resource "google_cloudbuild_trigger" "trigger_create-image" {

  name     = "create-image"
  location = "global"
  filename = "cloudbuild-image.yaml"

  source_to_build {
    uri       = "https://source.developers.google.com/p/${var.project_id}/r/GCP_CloudBuild_Exercises"
    ref       = "refs/heads/master"
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  depends_on = [google_sourcerepo_repository.source-repo]
}

resource "google_cloudbuild_trigger" "trigger_cicd-sample-app" {

  name            = "cicd-sample-app"
  location        = "global"
  filename        = "cloudbuild-cicd.yaml"
  service_account = google_service_account.cloudbuild_service_account.id

  trigger_template {
    branch_name = ".*"
    repo_name   = google_sourcerepo_repository.source-repo.name
  }

}
