

resource "yandex_compute_disk" "disk-task-3" {
  count = 3
  name        = "disk-task-3-${count.index}"
  type       = var.disk_task-3.type
  zone       = var.default_zone
  size       = var.disk_task-3.size
  block_size = var.disk_task-3.block_size
}
resource "yandex_compute_instance" "task3" {
  name        = "node-task3"
  platform_id = var.vm_platform_id
  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  dynamic secondary_disk {
    for_each = "${yandex_compute_disk.disk-task-3.*.id}"

    content {
      disk_id = yandex_compute_disk.disk-task-3["${secondary_disk.key}"].id
      auto_delete = var.disk_task-3.auto_delete
    }

 }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = false
    security_group_ids = [
      "${yandex_vpc_security_group.example.id}"
    ]
  }

  metadata = {
    serial-port-enable = var.vm_metadata.serial-port-enable
    ssh-keys           = local.ssh-keys
  }
  allow_stopping_for_update = true

  depends_on = [
    yandex_compute_disk.disk-task-3,
    yandex_vpc_security_group.example,
    yandex_vpc_subnet.develop
  ]

}


