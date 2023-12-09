terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
}


resource "yandex_iam_service_account" "sa" {
  name = var.sa_name
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}
// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "lamp" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket.name
  max_size   = var.bucket.max_size
  default_storage_class = var.bucket.storage_class
  anonymous_access_flags {
    read = true
    list = false
  }
}

//Загружаем картинку
resource "yandex_storage_object" "lamp-object" {
  depends_on = [yandex_storage_bucket.lamp]
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket.name
  key        = var.bucket.key
  source     = var.bucket.file
}




data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    username       = var.username
    ssh_public_key = file(var.ssh_public_key)
    packages       = jsonencode(var.packages)
  }
}


resource "yandex_compute_image" "lamp" {
  source_family = "lamp"
}

//Создаём  VPC
resource "yandex_vpc_network" "lamp_net" {
  name = var.vpc_name
}
resource "yandex_vpc_security_group" "lamp-sg" {
  name       = "lamp-sg"
  network_id = yandex_vpc_network.lamp_net.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}
//Создаём в VPC subnet с названием public, сетью 192.168.10.0/24.
resource "yandex_vpc_subnet" "public" {
  name           = var.subnet_public
  zone           = var.default_zone
  network_id     = yandex_vpc_network.lamp_net.id
  v4_cidr_blocks = var.default_cidr

}

//Создаём instance_group
resource "yandex_compute_instance_group" "lamp-ig" {
  depends_on = [yandex_iam_service_account_static_access_key.sa-static-key]
  name                = "lamp-ig"
  folder_id           = var.folder_id
  service_account_id  = "${yandex_iam_service_account.sa.id}"
  deletion_protection = false
  instance_template {
    platform_id = var.vm_resources.platform_id
    resources {
      core_fraction = var.vm_resources.core_fraction
      cores         = var.vm_resources.cores
      memory        = var.vm_resources.memory
    }

    boot_disk {
      mode = var.vm_resources.boot_disk_mode
      initialize_params {
        image_id = yandex_compute_image.lamp.id
      }
    }
    scheduling_policy {
      preemptible = true
    }
    network_interface {
      subnet_ids          = [yandex_vpc_subnet.public.id]
      security_group_ids = [yandex_vpc_security_group.lamp-sg.id]
      nat                = false

    }

    metadata = {
      user-data = data.template_file.cloudinit.rendered
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name        = "lamp-group"
    target_group_description = "load balancer target group"
  }
}
//Создаём сетевой балансировщик
resource "yandex_lb_network_load_balancer" "lamp-lb" {
  name = "lamp-lb"

  listener {
    name = "lamp-lb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp-ig.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}