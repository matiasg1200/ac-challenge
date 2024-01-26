# Create Windows compute instance
resource "google_compute_instance" "instance-1" {
  name         = "instance-1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"

  boot_disk {
    auto_delete = true
    device_name = "instance-1"
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240111"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    sysprep-specialize-script-cmd = "googet -noconfirm=true install google-compute-engine-ssh"
    enable-windows-ssh            = "TRUE"
    windows-startup-script-url    = "https://storage.googleapis.com/ac-devops-chg-01-2024/startup.ps1"
  }

  scheduling {
    automatic_restart  = false
    preemptible        = true
    provisioning_model = "SPOT"
  }

  depends_on = [
    google_storage_bucket.bucket-script,
    google_storage_bucket_object.object-script
  ]

}

# Create public access Storage Bucket for startup script 
resource "google_storage_bucket_access_control" "bucket_rule-script" {
  bucket = google_storage_bucket.bucket-script.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket" "bucket-script" {
  name     = "ac-devops-chg-01-2024"
  location = "US"
}

# Upload script to Storage Bucket
resource "google_storage_object_access_control" "object_rule-script" {
  object = google_storage_bucket_object.object-script.output_name
  bucket = google_storage_bucket.bucket-script.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_object" "object-script" {
  name   = "startup.ps1"
  source = "./scripts/startup.ps1"
  bucket = google_storage_bucket.bucket-script.id
}

# Create RSA key of size 4096 bits for compute engine instance
resource "tls_private_key" "key-pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to a file
resource "local_file" "private_key_file" {
  content  = tls_private_key.key-pair.private_key_openssh
  filename = "ac_challenge_key.pem"
}

# Save public key to a file
resource "local_file" "public_key_file" {
  content  = tls_private_key.key-pair.public_key_openssh
  filename = "ac_challenge_key.pub"
  
  # update the public key to add a username (required by GCP)
  provisioner "local-exec" {
    command = "truncate -s 724 ac_challenge_key.pub && sed -i '1s/^/challenge:/' ac_challenge_key.pub"
  }
}
# Create Storage Bucket to store keys
resource "google_storage_bucket" "bucket-keys" {
  name     = "ac-devops-chg-01-2024-keys"
  location = "US"
}

# Upload private key to Storage Bucket
resource "google_storage_bucket_object" "object-key" {
  name   = "ac_challenge_key.pem"
  source = "./ac_challenge_key.pem"
  bucket = google_storage_bucket.bucket-keys.id
  depends_on = [ local_file.private_key_file ]
}

module "gcloud" {
  source  = "terraform-google-modules/gcloud/google"

  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "compute instances add-metadata ${google_compute_instance.instance-1.name} --metadata-from-file ssh-keys=ac_challenge_key.pub --zone ${google_compute_instance.instance-1.zone}"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "compute instances add-metadata my-vm --metadata-from-file ssh-keys=ac_challenge_key.pub --zone ${google_compute_instance.instance-1.zone}"
  module_depends_on = [ google_compute_instance.instance-1 ]

}