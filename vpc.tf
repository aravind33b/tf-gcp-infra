resource "google_compute_network" "vpc_network" {
  for_each                = var.vpcs
  name                    = each.key
  auto_create_subnetworks = false
  routing_mode            = var.network_routing_mode
  delete_default_routes_on_create = true
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
  private_ip_google_access = true
}

resource "google_compute_route" "webapp_route" {
  for_each      = var.vpcs
  name          = "${each.key}-route"
  dest_range    = var.dest_range
  network       = google_compute_network.vpc_network[each.key].self_link
  next_hop_gateway = var.next_hop_gateway
  tags = ["webapp"]
}

resource "google_compute_subnetwork" "serverless" {
  for_each      = var.vpcs
  ip_cidr_range = "10.0.3.0/28"
  name          = "${each.key}-serverless"
  network       = google_compute_network.vpc_network[each.key].id
  region        = var.region
}

resource "google_vpc_access_connector" "connector" {
  for_each      = var.vpcs
  name          = "vpc-con"
  subnet {
    name = google_compute_subnetwork.serverless[each.key].name
  }
  machine_type = "f1-micro"
}