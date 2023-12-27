###cloud vars
variable "service_account_key_file" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "private_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "netology"
  description = "VPC network&subnet name"
}
variable "subnet_public" {
  type        = string
  default     = "public"
  description = "VPC network&subnet name"
}
variable "subnet_private" {
  type        = string
  default     = "private"
  description = "VPC network&subnet name"
}
variable "public_key" {
  type    = string
  default = ""
}

variable "username" {
  type = string
}
variable "ssh_public_key" {
  type        = string
  description = "Location of SSH public key."
}

variable "packages" {
  type    = list(any)
  default = []
}

variable "vm_resources" {
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    boot_disk_mode = "READ_WRITE"
    platform_id = "standard-v3"
    disk_size = 30
    disk_type = "network-hdd"
  }
}
variable "sa_name" {
  type = string
  default = ""
}

variable "mynet" {
  type    = string
  default = "mynet"
}

variable  "mysubnet-a" {
  type = map(any)
  default = {
    name           = "mysubnet-a"
    zone           = "ru-central1-a"
    v4_cidr_blocks = "10.13.0.0/24"
  }
}

variable  "mysubnet-b" {
  type = map(any)
  default = {
    name           = "mysubnet-b"
    zone           = "ru-central1-b"
    v4_cidr_blocks = "10.13.1.0/24"
  }
}

variable  "mysubnet-c" {
  type = map(any)
  default = {
    name           = "mysubnet-c"
    zone           = "ru-central1-c"
    v4_cidr_blocks = "10.13.2.0/24"
  }
}
variable "mysql" {
  default = {
    name                = "my-mysql-3"
    environment         = "PRESTABLE"
    version             = "8.0"
    disk_size = 20
    disk_type_id  = "network-ssd"
    resource_preset_id = "b1.medium"
    db_name = "netology_db"
    db_sa_name = ""
    db_sa_pass = ""
    back_hours = 23
    back_minutes = 59
    maint_window_type = "ANYTIME"
  }
}

variable "db_sa_name" {
  type = string
  default = ""
}
variable "db_sa_pass" {
  type = string
  default = ""
}

variable "k8s-net" {
  type    = string
  default = "k8s-net"
}

variable  "k8s-subnet-a" {
  type = map(any)
  default = {
    name           = "k8s-subnet-a"
    zone           = "ru-central1-a"
    v4_cidr_blocks = "10.5.0.0/24"
  }
}

variable  "k8s-subnet-b" {
  type = map(any)
  default = {
    name           = "k8s-subnet-b"
    zone           = "ru-central1-b"
    v4_cidr_blocks = "10.6.0.0/24"
  }
}

variable  "k8s-subnet-c" {
  type = map(any)
  default = {
    name           = "k8s-subnet-c"
    zone           = "ru-central1-c"
    v4_cidr_blocks = "10.7.0.0/24"
  }
}

variable "k8s_node_group" {
  default = {
    region      = "ru-central1"
    name        = "k8s-node-group"
    version     = "1.25"
    min         = 3
    max         = 6
    initial     = 3
    container_runtime = "containerd"
 }
}