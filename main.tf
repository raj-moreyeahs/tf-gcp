terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "service-by-tf"
  region      = "us-west1"
  credentials = "<key-path>"
}

resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}

resource "google_compute_firewall" "vpc_network_firewall" {
  name    = "vpcnetworkfirewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_subnetwork" "subnet1_us-west1" {
  name          = "subnet1"
  region        = "us-west1"
  ip_cidr_range = "192.168.1.0/24"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "subnet2_us-west1" {
  name          = "subnet2"
  region        = "us-west1"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "subnet3_us-east1" {
  name          = "subnet3"
  region        = "us-east1"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_instance" "instance1" {
  name         = "instance1"
  machine_type = "e2-micro"
  zone         = "us-west1-b"
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet1_us-west1.self_link
    access_config {}
  }
}

resource "google_compute_instance" "instance2" {
  name         = "instance2"
  machine_type = "e2-micro"
  zone         = "us-west1-c"
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet2_us-west1.self_link
    access_config {}
  }
}

resource "google_compute_instance" "instance3" {
  name         = "instance3"
  machine_type = "e2-micro"
  zone         = "us-east1-c"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet3_us-east1.self_link
    access_config {}
  }
}
