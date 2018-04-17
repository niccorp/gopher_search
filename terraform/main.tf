provider "azurerm" {}

/*
terraform {
  backend "atlas" {
    name = "niccorp/gopher-search-dev"
  }
}
*/
resource "azurerm_resource_group" "default" {
  name     = "${var.namespace}-rg-${var.env}"
  location = "${var.location}"

  tags {
    environment = "${var.env}"
    application = "gopher_search"
  }
}

module "network" "demo-network" {
  source              = "github.com/nicholasjackson/terraform-azurerm-network"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  subnet_prefixes     = "${var.subnet_prefixes}"
  subnet_names        = "${var.subnet_names}"
  vnet_name           = "${var.namespace}-vnet-${var.env}"
  sg_name             = "${var.namespace}-sg-${var.env}"
}

module "loadbalancer" "demo-lb" {
  #source                = "Azure/loadbalancer/azurerm"
  source              = "github.com/nicholasjackson/terraform-azurerm-loadbalancer"
  resource_group_name = "${azurerm_resource_group.default.name}"
  location            = "${var.location}"
  prefix              = "${var.namespace}-${var.env}"

  lb_port = {
    http = ["80", "Tcp", "3000"]
  }

  frontend_name = "${var.namespace}-public-ip-${var.env}"
}

module "computegroup" "demo-web" {
  source                                 = "github.com/nicholasjackson/terraform-azurerm-computegroup"
  resource_group_name                    = "${azurerm_resource_group.default.name}"
  location                               = "${var.location}"
  vmscaleset_name                        = "${var.namespace}-vmss-${var.env}"
  vm_size                                = "Standard_A0"
  nb_instance                            = 3
  vm_os_simple                           = "UbuntuServer"
  vnet_subnet_id                         = "${module.network.vnet_subnets[0]}"
  load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"

  cmd_extension = "sh install.sh ${azurerm_postgresql_server.test.fqdn} ${var.db_user}@${azurerm_postgresql_server.test.name} ${var.db_pass}"
  cmd_script    = "https://github.com/nicholasjackson/gopher_search/releases/download/v0.1/install.sh"

  admin_username = "azureuser"
  admin_password = "BestPasswordEver"
  ssh_key        = "${var.ssh_key_public}"
}

resource "azurerm_network_security_rule" "allowInternet80" {
  name                        = "allow-internet-port-80"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 200
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  protocol                    = "Tcp"
  resource_group_name         = "${azurerm_resource_group.default.name}"
  network_security_group_name = "${module.network.security_group_name}"
}

resource "azurerm_network_security_rule" "allowInternet3000" {
  name                        = "allow-internet-port-3000"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 205
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "3000"
  protocol                    = "Tcp"
  resource_group_name         = "${azurerm_resource_group.default.name}"
  network_security_group_name = "${module.network.security_group_name}"
}

resource "azurerm_network_security_rule" "allowJumpboxSSH" {
  name                        = "allow-jumpbox-ssh"
  direction                   = "Inbound"
  access                      = "Allow"
  priority                    = 210
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "${azurerm_network_interface.jumpbox.private_ip_address}"
  destination_port_range      = "22"
  protocol                    = "Tcp"
  resource_group_name         = "${azurerm_resource_group.default.name}"
  network_security_group_name = "${module.network.security_group_name}"
}
