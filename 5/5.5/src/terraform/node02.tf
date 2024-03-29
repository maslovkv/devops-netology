resource "yandex_compute_instance" "node02" {
  name                      = "node02"
  zone                      = "ru-central1-b"
  hostname                  = "node02.netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.centos-7-base}"
      name        = "root-node02"
      type        = "network-nvme"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.default.id}"
    nat        = true
    ip_address = "192.168.101.12"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_ed25519.pub")}"
  }
}
