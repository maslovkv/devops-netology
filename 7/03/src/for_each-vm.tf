
variable "nodes" {
  description = "Nodes and resources"
  type = list(object({
    vm_name = string
    cpu = number
    ram = number
    disk = number
    serial-port-enable = number
    }))
     default = [
    {
      vm_name = "node-01"
      cpu = 2
      ram = 1
      disk = 5
      serial-port-enable = 1
    },
    {
      vm_name = "node-02"
      cpu = 2
      ram = 2
      disk = 10
      serial-port-enable = 1
    },
   ]
}

resource "yandex_compute_instance" "nodes" {
  for_each     = {
    for vm in var.nodes:
    vm.vm_name => vm
  }

  name = "${each.value.vm_name}"
  resources {
    cores         = "${each.value.cpu}"
    memory        = "${each.value.ram}"
    core_fraction = var.vm_web_resources.core_fraction
  }
  platform_id = var.vm_platform_id
   boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = "${each.value.disk}"
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = "${each.value.serial-port-enable}"
    ssh-keys           = local.ssh-keys
  }
  allow_stopping_for_update = true
  depends_on = [yandex_compute_instance.web]
}
