variable "project_id" {
  description = "GCP project Id to deploy resoruces"
  type = string
}

variable "iam_roles" {
  description = "A list of the required roles for the Service account to deploy on Cloud Run"
  type = map
}
