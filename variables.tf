variable "project" {
  description = "The GCP project ID"
  type = string
  default = "csye-6225-terraform-packer"
}

variable "region" {
  description = "The GCP region"
  type = string
  default = "us-central1"
}

variable "zone" {
    description = "The GCP zone"
    type = string
    default = "us-central1-a"
}

variable "vpc_names" {
  description = "Names of the VPCs to create"
  type        = list(string)
  default     = ["vpc1", "vpc2"]
}

variable "network_routing_mode" {
  description = "routing mode for VPC"
  type = string
  default = "REGIONAL"
}

variable "next_hop_gateway" {
  description = "gateway for webapp"
  type = string
  default = "default-internet-gateway"
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    region                 = string
    webapp_subnet_cidr     = string
    db_subnet_cidr         = string
  }))
}

variable "webapp_subnet_cidr" {
    description = "web_subnet description"
    type = string
    default = "10.0.1.0/24"
}

variable "dbapp_subnet_cidr" {
    description = "db_subnet description"
    type = string
    default = "10.0.2.0/24"
}
variable "instance_vpc_name" {
  description = "Name of the VPC for the custom instance"
  type        = string
  default     = "vpc1"
}
variable "machine_type" {
  description = "Machine type"
  type = string
  default = "e2-medium"
}

variable "size" {
  description = "Disk size"
  default = "100"
}

variable "type" {
  description = "Boot disk type"
  default = "pd-standard"
}

variable "image" {
  description = "Disk image"
  default = "centos-stream-8"
}

variable "protocol" {
  description = "protocol type"
  default = "tcp"
}

variable "httpport" {
  description = "http ports allowed"
  default = "8080"
}

variable "sshport" {
  description = "http ports denied"
  default = "22"
}

variable "source_ranges" {
  description = "source ranges"
  default = "0.0.0.0/0"
}

variable "dest_range" {
  description = "dest_range"
  default = "0.0.0.0/0"
}

variable "database_version" {
  type        = string
  default     = "POSTGRES_15"
  description = "Database version for DB instance"
}

variable "pass_Len" {
  type        = number
  default     = 16
  description = "Database random password length"
}

variable "webapp_name" {
  type        = string
  default     = "webapp"
  description = "Application all constant"
}

variable "db_tier" {
  type        = string
  default     = "db-custom-1-3840"
  description = "Database vm instance tier"
}

variable "db_availability_type" {
  type        = string
  default     = "REGIONAL"
  description = "Database availability type"
}

variable "db_disk_size" {
  type        = number
  default     = 100
  description = "Database disk size"
}

variable "db_disk_type" {
  type        = string
  default     = "PD_SSD"
  description = "Database disk type - hdd/ssd"
}

variable "db_address_purpose" {
  type        = string
  default     = "VPC_PEERING"
  description = "Database global compute address purpose"
}

variable "db_address_prefix" {
  type        = number
  default     = 24
  description = "Database global compute address cidr prefix"
}

variable "db_address_type" {
  type        = string
  default     = "INTERNAL"
  description = "Database global compute address type"
}