module "network" {
  source              = "Azure/network/azurerm"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
}

module "loadbalancer" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${azurerm_resource_group.default.name}"
  location            = "${var.location}"
  prefix              = "terraform-test"

  "lb_port" {
    http = ["80", "Tcp", "80"]
  }
}

module "computegroup" {
  source                                 = "Azure/computegroup/azurerm"
  resource_group_name                    = "${azurerm_resource_group.default.name}"
  location                               = "${var.location}"
  vm_size                                = "Standard_A0"
  admin_username                         = "azureuser"
  admin_password                         = "ComplexPassword"
  ssh_key                                = "~/.ssh/server_rsa.pub"
  nb_instance                            = 2
  vm_os_simple                           = "UbuntuServer"
  vnet_subnet_id                         = "${module.network.vnet_subnets[0]}"
  load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"

  cmd_extension = "wget -O install.sh https://github.com/nicholasjackson/gopher_search/releases/download/v0.1/install.sh && chmod +x ./install.sh && ./install.sh ${azurerm_postgresql_server.test.fqdn} ${var.db_user} ${var.db_pass}"

  lb_port = {
    http = ["80", "Tcp", "3000"]
  }

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}
