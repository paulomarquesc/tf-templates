provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_string" "test" {
  length = 12
  special = true
}

locals {
  admin_username    = "testadmin"
  admin_password    = random_string.test.result
}

resource "azurerm_resource_group" "test" {
  name     = "${var.prefix}-resources"
  location = var.location

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true",
    "SkipNRMSNSG"      = "true"
  }
}

resource "azurerm_network_security_group" "test" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.6.0.0/16"]

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_subnet" "test" {
  name                 = "${var.prefix}-delegated-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.6.2.0/24"]

  delegation {
    name = "testdelegation"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "test1" {
  name                      = "${var.prefix}-hosts-subnet"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.test.name
  address_prefixes          = ["10.6.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "${var.prefix}-ppg"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_availability_set" "test" {
  name                = "${var.prefix}-avset"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  proximity_placement_group_id = azurerm_proximity_placement_group.test.id
  
  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_network_interface" "test" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test1.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_M8ms"
  admin_username                  = local.admin_username
  admin_password                  = local.admin_password
  disable_password_authentication = false
  proximity_placement_group_id    = azurerm_proximity_placement_group.test.id
  availability_set_id             = azurerm_availability_set.test.id
  network_interface_ids = [
    azurerm_network_interface.test.id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    "platformsettings.host_environment.service.platform_optedin_for_rootcerts" = "true",
    "CreatedOnDate"                                                            = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack"                                                         = "true",
    "Owner"                                                                    = "testadmin"
  }
}

resource "azurerm_netapp_account" "test" {
  name                = "${var.prefix}-netapp-account"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  depends_on = [
    azurerm_subnet.test,
    azurerm_subnet.test1
  ]

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_netapp_pool" "test" {
  name                = "${var.prefix}-netapp-pool"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  service_level       = "Standard"
  size_in_tb          = 8
  qos_type            = "Manual"

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}


resource "azurerm_netapp_volume_group_sap_hana" "test" {
  name                   = "${var.prefix}-netapp-volumegroup"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  account_name           = azurerm_netapp_account.test.name
  group_description      = "Test volume group"
  application_identifier = "TST"
  
  volume {
    name                         = "${var.prefix}-netapp-volume-1"
    volume_path                  = "my-unique-file-path-1"
    service_level                = "Standard"
    capacity_pool_id             = azurerm_netapp_pool.test.id
    subnet_id                    = azurerm_subnet.test.id
    proximity_placement_group_id = azurerm_proximity_placement_group.test.id
    volume_spec_name             = "data"
    storage_quota_in_gb          = 1024
    throughput_in_mibps          = 24
    protocols                    = ["NFSv4.1"]
    security_style               = "Unix"
    snapshot_directory_visible   = false
    
    export_policy_rule {
      rule_index            = 1
      allowed_clients       = "0.0.0.0/0"
      nfsv3_enabled         = false
      nfsv41_enabled        = true
      unix_read_only        = false
      unix_read_write       = true
      root_access_enabled   = false
    }
  
    tags = {
      "CreatedOnDate"    = "2022-07-08T23:50:21Z",
      "SkipASMAzSecPack" = "true"
    }
  }

  volume {
    name                         = "${var.prefix}-netapp-volume-2"
    volume_path                  = "my-unique-file-path-2"
    service_level                = "Standard"
    capacity_pool_id             = azurerm_netapp_pool.test.id
    subnet_id                    = azurerm_subnet.test.id
    proximity_placement_group_id = azurerm_proximity_placement_group.test.id
    volume_spec_name             = "log"
    storage_quota_in_gb          = 1024
    throughput_in_mibps          = 24
    protocols                    = ["NFSv4.1"]
    security_style               = "Unix"
    snapshot_directory_visible   = false
    
    export_policy_rule {
      rule_index            = 1
      allowed_clients       = "0.0.0.0/0"
      nfsv3_enabled         = false
      nfsv41_enabled        = true
      unix_read_only        = false
      unix_read_write       = true
      root_access_enabled   = false
    }
  
    tags = {
      "CreatedOnDate"    = "2022-07-08T23:50:21Z",
      "SkipASMAzSecPack" = "true"
    }
  }

  volume {
    name                         = "${var.prefix}-netapp-volume-3"
    volume_path                  = "my-unique-file-path-3"
    service_level                = "Standard"
    capacity_pool_id             = azurerm_netapp_pool.test.id
    subnet_id                    = azurerm_subnet.test.id
    proximity_placement_group_id = azurerm_proximity_placement_group.test.id
    volume_spec_name             = "shared"
    storage_quota_in_gb          = 1024
    throughput_in_mibps          = 24
    protocols                    = ["NFSv4.1"]
    security_style               = "Unix"
    snapshot_directory_visible   = false
    
    export_policy_rule {
      rule_index            = 1
      allowed_clients       = "0.0.0.0/0"
      nfsv3_enabled         = false
      nfsv41_enabled        = true
      unix_read_only        = false
      unix_read_write       = true
      root_access_enabled   = false
    }
  
    tags = {
      "CreatedOnDate"    = "2022-07-08T23:50:21Z",
      "SkipASMAzSecPack" = "true"
    }
  }

  depends_on = [
    azurerm_linux_virtual_machine.test,
    azurerm_proximity_placement_group.test
  ]
}