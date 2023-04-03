terraform {
  required_providers {
      yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
}


# 4 Задание.

resource "yandex_vpc_network" "develop" {
  count = var.env_name == "develop" ? 1 :   0
  name = var.env_name
}

resource "yandex_vpc_subnet" "develop" {
  count = var.env_name == "develop" ?  length(var.subnets) : 0
  name = "${var.env_name}-${var.subnets[count.index].zone}"
  zone = var.subnets[count.index].zone
  network_id     = yandex_vpc_network.develop[0].id
  v4_cidr_blocks = ["${var.subnets[count.index].cidr}"]

}

resource "yandex_vpc_network" "production" {
  count = var.env_name == "production" ? 1 : 0
  name = var.env_name
}

resource "yandex_vpc_subnet" "production" {
  count          = var.env_name == "production" ?  length(var.subnets) : 0
  name           = "${var.env_name}-${var.subnets[count.index].zone}"
  zone           = var.subnets[count.index].zone
  network_id     = yandex_vpc_network.production[0].id
  v4_cidr_blocks = ["${var.subnets[count.index].cidr}"]
}
