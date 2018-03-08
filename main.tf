provider "azurerm" {
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
  name     = "${var.name_prefix}-rg"
  location = "${var.location}"

  tags {
    environment = "${var.environment}"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}vnet"
  location            = "${var.location}"
  address_space       = ["${var.vnet_address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    environment = "${var.environment}"
  }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_address_space}"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

security_rule {
  name                        = "${var.name_prefix}rulessh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
 }

  tags {
    environment = "${var.environment}"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "${var.name_prefix}nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name                          = "${var.name_prefix}ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
  }

  depends_on = ["azurerm_network_security_group.nsg"]

  tags {
    environment = "${var.environment}"
  }
}

# Create public ip
resource "azurerm_public_ip" "publicip" {
  name                         = "${var.name_prefix}-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.hostname}"

  tags {
    environment = "${var.environment}"
  }
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "stor" {
  name                      = "${var.hostname}stor"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  account_tier              = "${var.storage_account_type}"
  account_replication_type  = "LRS"

  tags {
    environment = "${var.environment}"
  }
}

# Create container storage
resource "azurerm_storage_container" "storc" {
  name                  = "${var.name_prefix}-vhds"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.stor.name}"
  container_access_type = "private"
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.name_prefix}vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "${var.name_prefix}osdisk"
    vhd_uri       = "${azurerm_storage_account.stor.primary_blob_endpoint}${azurerm_storage_container.storc.name}/${var.name_prefix}osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.disable_password_authentication}"

    ssh_keys = [{
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.ssh_public_key}"
    }]
  }

  depends_on = ["azurerm_storage_account.stor"]

  tags {
    environment = "${var.environment}"
  }
}

output "admin_username" {
  value = "${var.admin_username}"
}

output "vm_fqdn" {
  value = "${azurerm_public_ip.publicip.fqdn}"
}

