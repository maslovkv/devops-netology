
output "dev_net" {
  value = zipmap(yandex_vpc_network.develop.*.name, yandex_vpc_network.develop.*.id)
}
output "dev_subnet" {
  value = zipmap(yandex_vpc_subnet.develop.*.name, yandex_vpc_subnet.develop.*.id)
}

output "prod_net" {
  value =  zipmap(yandex_vpc_network.production.*.name, yandex_vpc_network.production.*.id)
}
output "prod_subnet" {
  value = zipmap(yandex_vpc_subnet.production.*.name, yandex_vpc_subnet.production.*.id)
}
output "prod_zones" {
  value = zipmap(yandex_vpc_subnet.production.*.zone, yandex_vpc_subnet.production.*.id)
}