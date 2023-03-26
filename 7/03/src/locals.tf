locals {
  ssh-keys  = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  nodes = [yandex_compute_instance.nodes["node-01"], yandex_compute_instance.nodes["node-02"]]
  all_nodes = [yandex_compute_instance.nodes["node-01"], yandex_compute_instance.nodes["node-02"], data.yandex_compute_instance.task3[*], data.yandex_compute_instance.web[*]]
  }