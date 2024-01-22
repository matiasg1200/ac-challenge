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

  service_account {
    email  = "285657077755-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_storage_bucket.bucket,
    google_storage_bucket_object.object
  ]

}

# Create public access Storage Bucket for startup script 
resource "google_storage_bucket_access_control" "bucket_rule" {
  bucket = google_storage_bucket.bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket" "bucket" {
  name     = "ac-devops-chg-01-2024"
  location = "US"
}

# Upload script to Storage Bucket
resource "google_storage_object_access_control" "object_rule" {
  object = google_storage_bucket_object.object.output_name
  bucket = google_storage_bucket.bucket.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_object" "object" {
  name   = "startup.ps1"
  source = "./scripts/startup.ps1"
  bucket = google_storage_bucket.bucket.name
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

# Save private key to a file
resource "local_file" "public_key_file" {
  content  = tls_private_key.key-pair.public_key_openssh
  filename = "ac_challenge_key.pub"
}
