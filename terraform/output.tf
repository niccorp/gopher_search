output "bastion_host" {
  value = "${azurerm_public_ip.jumpbox.ip_address}"
}

output "postgresql_fqdn" {
  value = "${azurerm_postgresql_server.test.fqdn}"
}

/*
output "http_endpoint" {
  value = "${module.loadbalancer.azurerm_public_ip_address}"
}
*/

