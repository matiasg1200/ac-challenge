resource "google_sourcerepo_repository" "source-repo" {
  name = "source-devops-repo"
}

resource "google_artifact_registry_repository" "artifcat-repo" {
  location      = "us-central1"
  repository_id = "artifact-devops-repo"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

resource "google_cloudbuild_trigger" "trigger" {
  location = "us-central1"
  filename = "cloudbuild.yaml"

  trigger_template {
    branch_name = "*"
    repo_name   = google_sourcerepo_repository.source-repo.name
  }

}