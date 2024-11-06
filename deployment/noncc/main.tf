provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "azurg" {
  name     = "future.ai-rg-SASTChkmx"
  location = "West US"
}

# generate a random prefix
resource "random_string" "azustring" {
  length  = 16
  special = false
  upper   = false
  number  = false

}

# Storage account to hold diag data from VMs and Azure Resources
resource "azurerm_storage_account" "azusa" {
  name                     = random_string.azustring.result
  resource_group_name      = azurerm_resource_group.azurg.name
  location                 = azurerm_resource_group.azurg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

# Route Table for Azure Virtual Network and Server Subnet
resource "azurerm_route_table" "azurt" {
  name                          = "AzfwRouteTable"
  resource_group_name           = azurerm_resource_group.azurg.name
  location                      = azurerm_resource_group.azurg.location
  disable_bgp_route_propagation = false

  route {
    name                   = "AzfwDefaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance" #VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None
    next_hop_in_ip_address = "10.0.1.4"
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

# Virtual network for azure firewall and servers
resource "azurerm_virtual_network" "azuvnet" {
  name                = "virtualNetwork1"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

#gateway


##gateway subnet start

resource "azurerm_subnet" "azusubnetgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_public_ip" "azugwpip" {
  name                = "gateway-pip"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "azuvnetgw" {
  name                = "VNetGateway1"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name

  type     = "Vpn"
  vpn_type = "PolicyBased"
  sku      = "Basic"

  ip_configuration {
     name                          = "vnetGatewayConfig"
     public_ip_address_id          = azurerm_public_ip.azugwpip.id
     private_ip_address_allocation = "Dynamic"
     subnet_id                     = azurerm_subnet.azusubnetgw.id
  }
}

##gateway subnet end


# Subnet for Bastion, App Servers, DB Servers,  Firewall and Route Table Association
resource "azurerm_subnet" "azusubnetjb" {
  name                 = "BastionSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "azusubnetbastionsrv" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_subnet" "azusubnetfw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "azusubnetapp" {
  name                 = "AppSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_route_table_association" "azurtassocapp" {
  subnet_id      = azurerm_subnet.azusubnetapp.id
  route_table_id = azurerm_route_table.azurt.id
}

resource "azurerm_subnet" "azusubnetdb" {
  name                 = "DBSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet_route_table_association" "azurtassocdb" {
  subnet_id      = azurerm_subnet.azusubnetdb.id
  route_table_id = azurerm_route_table.azurt.id
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "azufwpip" {
  name                = "azureFirewalls-pip"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
}

# Public IP for Bastion
resource "azurerm_public_ip" "azujumppip" {
  name                = "Bastion-pip"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
}

/*
#Azure Bastion Service start
resource "azurerm_bastion_host" "example" {
  name                = "BastionHost"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.azusubnetbastionsrv.id
    public_ip_address_id = azurerm_public_ip.azujumppip.id
  }
}

#Azure Bastion Service end
*/
/*
#Azure bastion example

module "azure-bastion" {
  source  = "kumarvna/azure-bastion/azurerm"
  version = "1.2.0"

  # Resource Group, location, VNet and Subnet details
  resource_group_name = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name

  # Azure bastion server requireemnts
  azure_bastion_service_name          = "bastion-service"
  azure_bastion_subnet_address_prefix = azurerm_subnet.azusubnetbastionsrv.address_prefixes
  bastion_host_sku                    = "Standard"
  scale_units                         = 10

  # Adding TAG's to your Azure resources (Required)
  tags = {
    ProjectName  = "SASTChkmarx"
    Env          = "Dev"
    Owner        = "skondla@me.com"
    BusinessUnit = "IT"
    ServiceClass = "Gold"
  }
}
*/
# NSG for Bastion Server
resource "azurerm_network_security_group" "azunsgjb" {
  name                = "BastionNSG"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  security_rule {
    name                       = "ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22" 
    #source_address_prefix      = "*"
    source_address_prefix      =  "*"
    destination_address_prefix = "*"
    #destination_address_prefixes = [ "10.0.1.0/24","10.0.2.0/24"] #Outbound to App & DB subnets
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

# NSG for App Servers
resource "azurerm_network_security_group" "azunsgapp" {
  name                = "AppNSG"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  security_rule {
    name                       = "app"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80","443"]
    #source_address_prefix      = "*"
    #destination_address_prefix = "*"
    source_address_prefix      =  "*"  #should be replaced with Application gateway or Load Balancer public IP when configured + Bastion Subnet range
    destination_address_prefixes = ["10.0.0.0/24","10.0.1.0/24","10.0.3.0/24"]  #outbound to DB subnet
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

# NSG for DB Servers
resource "azurerm_network_security_group" "azunsgdb" {
  name                = "DBNSG"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  security_rule {
    name                       = "db"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["5432","1433"]
    #source_address_prefix      = "*"
    #destination_address_prefix = "*"
    source_address_prefixes      =  [ "10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]  #Inbound from App subnet and/or  loadbalancer fqdn if configured with HA
    destination_address_prefixes = ["10.0.2.0/24"]  
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

# Nic for Bastion Server
resource "azurerm_network_interface" "azunicjb" {
  name                = "BastionNIC"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetjb.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azujumppip.id
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azunicjb" {
  network_interface_id      = azurerm_network_interface.azunicjb.id
  network_security_group_id = azurerm_network_security_group.azunsgjb.id
}

# Nic for App Server
resource "azurerm_network_interface" "azunicappvm" {
  name                = "AppServerNIC"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetapp.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azunicappvm" {
  network_interface_id      = azurerm_network_interface.azunicappvm.id
  network_security_group_id = azurerm_network_security_group.azunsgapp.id
}



# Nic1 for DB Server1
resource "azurerm_network_interface" "azunicdbvm" {
  name                = "DBServerNIC"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetdb.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azunicdbvm" {
  network_interface_id      = azurerm_network_interface.azunicdbvm.id
  network_security_group_id = azurerm_network_security_group.azunsgdb.id
}

# Nic2 for DB Server2
resource "azurerm_network_interface" "azunicdbvm2" {
  name                = "DBServerNIC2"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetdb.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azunicdbvm2" {
  network_interface_id      = azurerm_network_interface.azunicdbvm2.id
  network_security_group_id = azurerm_network_security_group.azunsgdb.id
}

#Public SSH Key
resource "azurerm_ssh_public_key" "sshkey" {
  name                = "sshkey"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  public_key          = file("~/.ssh/futureai_sast_key.pub")
}

# Bastion VM 
resource "azurerm_linux_virtual_machine" "vmjb" {
  name                  = "Bastion"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  size                            = "Standard_D2ads_v5"
  admin_username                  = "adminuser"
  network_interface_ids = ["${azurerm_network_interface.azunicjb.id}"]

  admin_ssh_key {
    username = "adminuser"
    #public_key = file("~/.ssh/id_rsa.pub")
    public_key = azurerm_ssh_public_key.sshkey.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }

  depends_on = [azurerm_network_interface_security_group_association.azunicjb]
}

# App Server VM

resource "azurerm_linux_virtual_machine" "vmapp" {
  name                  = "AppVM1"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  size                            = "Standard_D2ads_v5"
  admin_username                  = "appadmin"
  network_interface_ids = ["${azurerm_network_interface.azunicappvm.id}"]

  admin_ssh_key {
    username = "appadmin"
    #public_key = file("~/.ssh/id_rsa.pub") #Use only pub key from bastion, Should be restricted from everywhere else. Once security hardened, restrict Access
    public_key = azurerm_ssh_public_key.sshkey.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }

  depends_on = [azurerm_network_interface_security_group_association.azunicappvm]
}

#DB Server VM

resource "azurerm_linux_virtual_machine" "vmdb" {
  name                  = "DBVM1"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  size                            = "Standard_D2ads_v5"
  admin_username                  = "dbadmin"
  network_interface_ids = ["${azurerm_network_interface.azunicdbvm.id}"]

  admin_ssh_key {
    username = "dbadmin"
    #public_key = file("~/.ssh/id_rsa.pub") #Use only pub key from bastion, Should be restricted from everywhere else. Once security hardened, restrict Access
    public_key = azurerm_ssh_public_key.sshkey.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }

  depends_on = [azurerm_network_interface_security_group_association.azunicdbvm]
}

# Windows DB Server VM 
/*
resource "azurerm_windows_virtual_machine" "WinVMServer" {
  name                  = "Win-DB-Server"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  network_interface_ids = ["${azurerm_network_interface.azunicdbvm2.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    #sku       = "2012-R2-Datacenter"
    sku       = "2022-datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "Server-OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "WinDBServer1"
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  }
  os_profile_windows_config {}
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.azusa.primary_blob_endpoint
  }


  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
  depends_on = [azurerm_network_interface_security_group_association.azunicdbvm2]
}

*/

resource "azurerm_windows_virtual_machine" "WinVMServer" {
  name                = "Win-DB-Server"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  size                = "Standard_F2"
  admin_username = var.adminUsername
  admin_password = var.adminPassword
  network_interface_ids = [
    azurerm_network_interface.azunicdbvm2.id,
  ]

  os_disk {
    name              = "Server-OSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"    
  }

  /*
  os_profile_windows_config {}
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.azusa.primary_blob_endpoint
  }
  */

  /*
  os_profile {
    computer_name  = "WinDBServer1"
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  } 
  */

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "Development"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
  depends_on = [azurerm_network_interface_security_group_association.azunicdbvm2]
}


# Azure Firewall
resource "azurerm_firewall" "azufw" {
  name                = "firewall1"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  #sku_tier            = "Standard"
  sku_tier            = "Premium"
  #sku_name            = "AZFW_Hub"
  sku_name            = "AZFW_VNet"
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.azusubnetfw.id
    public_ip_address_id = azurerm_public_ip.azufwpip.id
  }
}

# Azure Firewall Application Rule
resource "azurerm_firewall_application_rule_collection" "azufwappr1" {
  name                = "appRc1"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = azurerm_resource_group.azurg.name
  priority            = 101
  action              = "Allow"

  rule {
    name = "appRule1"

    source_addresses = [
      "10.0.0.0/24",
    ]

    target_fqdns = [
      "*.microsoft.com","*.future.ai.com",
    ]

    protocol {
      port = "443"
      type = "Https"
     }
  }
}

# Azure Firewall Network Rule
resource "azurerm_firewall_network_rule_collection" "azufwnetr1" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = azurerm_resource_group.azurg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "netRc1"

    source_addresses = [
      "10.0.0.0/24",
    ]

    destination_ports = [
      "8000-8999",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
    ]
  }
}

#Azure Firewall NAT Rule 

resource "azurerm_firewall_nat_rule_collection" "natrulecollect" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = azurerm_resource_group.azurg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "natrule1"

    source_addresses = [
      "10.0.0.0/16",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      azurerm_public_ip.azufwpip.ip_address
    ]

    translated_port = 53

    translated_address = "8.8.8.8"

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}

#Disk Encription Set

data "azurerm_client_config" "current" {}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

resource "azurerm_key_vault" "kvault" {
  name                        = "des-sast-keyvault-1"
  location                    = azurerm_resource_group.azurg.location
  resource_group_name         = azurerm_resource_group.azurg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_key" "kvkey" {
  name         = "des-keyvault-key"
  key_vault_id = azurerm_key_vault.kvault.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.kv-access-user
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "encryptset" {
  name                = "des-encrypt-set"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  key_vault_key_id    = azurerm_key_vault_key.kvkey.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "encrypt-disk" {
  key_vault_id = azurerm_key_vault.kvault.id

  tenant_id = azurerm_disk_encryption_set.encryptset.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.encryptset.identity.0.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "kv-access-user" {
  key_vault_id = azurerm_key_vault.kvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "Create",
    "Delete"
  ]
}