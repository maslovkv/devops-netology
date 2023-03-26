data "yandex_compute_instance" "web" {
  depends_on = [yandex_compute_instance.web]
  for_each     = {
    for i,vm in yandex_compute_instance.web[*]:
    vm.name => vm
  }
  name = "${each.value.name}"
}
data "yandex_compute_instance" "task3" {
  depends_on = [yandex_compute_instance.task3]
  for_each     = {
    for i,vm in yandex_compute_instance.task3[*]:
    vm.name  => vm
  }
  name = "${each.value.name}"
}

output "inst_web" {
  value =  [ for name in data.yandex_compute_instance.web : ["name  = ${name.name}", "id = ${name.id}", "fqdn = ${name.fqdn}"]]
}

output "inst_nodes" {
  value = [for name in local.nodes : ["name  = ${name.name}", "id = ${name.id}", "fqdn = ${name.fqdn}"]]
}

output "inst_task3" {
  value = [for name in data.yandex_compute_instance.task3 :  ["name  = ${name.name}", "id = ${name.id}", "fqdn = ${name.fqdn}"]]
}
/*
output "all_inst" {
  value = "%{ for name in local.all_nodes }${name}, %{ endfor }"
}
*/