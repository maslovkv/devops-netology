output "vpc_dev_net" {
  value = module.vpc_dev.dev_net
}
output "vpc_dev_subnet" {
  value = module.vpc_dev.dev_subnet

}
output "vpc_prod-net" {
  value = module.vpc_prod.prod_net
}
output "vpc_prod-subnet" {
  value = "${module.vpc_prod.prod_subnet}"
}
output "vpc_prod-zones" {
  value = "${module.vpc_prod.prod_zones}"
}