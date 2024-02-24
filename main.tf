terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.16.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  for_each                = var.vpcs
  name                    = each.key
  auto_create_subnetworks = false
  routing_mode            = var.network_routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_firewall" "allow_http" {
  for_each = var.vpcs
  name    = "${each.key}-allow-http"
  network = google_compute_network.vpc_network[each.key].self_link

  allow {
    protocol = var.protocol
    ports    = [var.httpport]
  }

  source_ranges = [var.source_ranges]
  target_tags = ["webapp"]
}

resource "google_compute_firewall" "deny_ssh" {
  for_each = var.vpcs
  name    = "${each.key}-deny-ssh"
  network = google_compute_network.vpc_network[each.key].self_link

  allow {
    protocol = var.protocol
    ports    = [var.sshport]
  }

  source_ranges = [var.source_ranges]
  target_tags = ["webapp"]
}

resource "google_compute_subnetwork" "webapp_subnet" {
  for_each      = var.vpcs
  name          = "${each.key}-webapp"
  ip_cidr_range = each.value.webapp_subnet_cidr
  region        = each.value.region
  network       = google_compute_network.vpc_network[each.key].self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db_subnet" {
  for_each      = var.vpcs
  name          = "${each.key}-db"
  ip_cidr_range = each.value.db_subnet_cidr
  region        = each.value.region
  network       = google_compute_network.vpc_network[each.key].self_link
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-password"

  replication {
    auto{}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = base64encode(random_password.password.result)
}

resource "google_sql_database" "database" {
  name     = var.dbname
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name             = "${var.dbname}-instance"
  database_version = var.db_version
  deletion_protection = false
  # region           = var.region
  # zone             = var.zone
  # availability_type = regional
  settings {
    tier = "db-f1-micro"
    disk_type = "pd-ssd"
    disk_size = var.disk_size
    # ipv4_enabled  = false
    # private_network = google_compute_network.VPC
  }
  # backup_configuration {
  #     enabled = true
  #     binary_log_enabled = true
  # }
  # resource "google_sql_user" "users" {
  # name     = "babuaravind"
  # instance = google_sql_database_instance.main.name
  # password =  random_password.password.result
  # }
}

resource "google_compute_route" "webapp_route" {
  for_each      = var.vpcs
  name          = "${each.key}-route"
  dest_range    = var.dest_range
  network       = google_compute_network.vpc_network[each.key].self_link
  next_hop_gateway = var.next_hop_gateway
  tags = ["webapp"]
}
resource "google_compute_instance" "custom_instance" {
  name         = "custom-instance-${var.instance_vpc_name}"
  machine_type = var.machine_type
  zone         = var.zone
  network_interface {
    subnetwork = google_compute_subnetwork.webapp_subnet[var.instance_vpc_name].self_link
    access_config {
    }
  }

  metadata = {
    DB_USER = "dbuser"
    DB_NAME = "dbname"
  }

  metadata_startup_script = "./startup-script.sh"

  boot_disk {
    initialize_params {
      image = var.image  # Reference to your existing custom image
      size  = var.size
      type  = var.type
    }
  }

  tags = ["webapp"]
}