variable "vm_image_family" {
  type        = string
  description = "OS release name"
  default     = "ubuntu-2004-lts"
}

variable "vm_platform_id" {
  type        = string
  description = "VM platform_id"
  default     =   "standard-v1"
}


variable "vm_metadata" {
  type = map
  default = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/ADybrpsPKe8bXTSBsxXOuhqq4rA9FvLXUPrUiy7hT mask@mask-note"
  }
}

variable "web-name" {
  type        = string
  description = "Name VM"
  default     =  "netology-develop-platform-web"
}

variable "vm_web_resources" {
  type = map
  default = {
    cores = 2
    memory = 1
    core_fraction = 5
  }
}

variable "db-name" {
  type        = string
  description = "Name VM"
  default     =  "netology-develop-platform-db"
}

variable "vm_db_resources" {
  type = map
  default = {
    cores = 2
    memory = 2
    core_fraction = 20
  }
}





