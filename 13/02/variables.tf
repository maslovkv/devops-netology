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
  type = map(any)
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    boot_disk_mode = "READ_WRITE"
    platform_id = "standard-v3"
  }
}
variable "sa_name" {
  type = string
  default = ""
}
variable "bucket" {
  type = map(any)
  default = {
    name = "lamp-bucket-netology-13-02"
    max_size  = "1073741824"
    storage_class = "STANDARD"
    key = "netology.jpeg"
    file = "netology.jpeg"
  }
}


#<a href="https://storage.yandexcloud.net/lamp-bucket-netology-13-02/netology.jpeg">Картинка тут</a>