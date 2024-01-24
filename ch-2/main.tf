resource "google_sourcerepo_repository" "source-repo" {
  name = "GCP_CloudBuild_Exercises"
  project = var.project_id
}

resource "google_cloudbuild_trigger" "trigger_create-image" {

  name        = "create-image"
  location = "us-central1"
  filename = "cloudbuild-image.yaml"

  source_to_build {
    uri       = "https://source.developers.google.com/p/${var.project_id}/r/GCP_CloudBuild_Exercises"
    ref       = "refs/heads/master"
    repo_type = "CLOUD_SOURCE_REPOSITORIES"
  }

  depends_on = [ google_sourcerepo_repository.source-repo ]
}

resource "google_cloudbuild_trigger" "trigger_cicd-sample-app" {

  name        = "cicd-sample-app"
  location = "us-central1"
  filename = "cloudbuild-cicd.yaml"

  trigger_template {
    branch_name = ".*"
    repo_name   = google_sourcerepo_repository.source-repo.name
  }

}