#Create a Terraform configuration with a backend configuration block

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n cctfstate --account-name "confcomptfstateokweo8hp" 
    EOT
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.2"
    }
  }
    backend "azurerm" {
        resource_group_name  = "conf-compute-tfstate"
        storage_account_name = "confcomptfstateokweo8hp"
        container_name       = "cxtfstate"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "azurg" {
  name     = "futureai-conf-compute-mvp"
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
  #name                     = random_string.azustring.result
  name                     = "${var.prefix}sa"
  resource_group_name      = azurerm_resource_group.azurg.name
  location                 = azurerm_resource_group.azurg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "CC_MVP" 
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
    next_hop_in_ip_address = "172.21.39.4" 
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

# Virtual network for azure firewall and servers
resource "azurerm_virtual_network" "azuvnet" {
  name                = "chkmrx-mvp-vnet1"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  address_space       = ["172.21.39.0/24"]
  #dns_servers         = ["168.63.129.16", "8.8.8.8"]
  dns_servers         = ["172.23.241.180","172.23.241.181"]

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}


# Subnet for Bastion, App Servers, DB Servers,  Firewall and Route Table Association

resource "azurerm_subnet" "azusubnetfw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  #address_prefixes     = ["172.21.39.1/26"]
  address_prefixes     = ["172.21.39.0/26"]
}

resource "azurerm_subnet" "azusubnetjb" {
  name                 = "BastionSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["172.21.39.64/29"]
}

/*
Azure Bastion Service (Azure Managed Service) and Bastion Host (VM) are two different resources. 
And AzureBastionSubnet requires a larger a large network address block (/26 or greater) and highly scalable, however waste network space.
Use Bastion Host VM as a normal VM deployment and harden host security and ssh (PKI)
*/

/*
resource "azurerm_subnet" "azubastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["172.21.39.72/29"]
}
*/

resource "azurerm_subnet" "endpoint" {
  name                                           = "AppEndPointSubnet"
  resource_group_name                            = azurerm_resource_group.azurg.name
  virtual_network_name                           = azurerm_virtual_network.azuvnet.name
  address_prefixes                               = ["172.21.39.80/28"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "azusubnetdb" {
  name                 = "DBSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["172.21.39.96/28"]
}

resource "azurerm_subnet" "azusubnetapp" {
  name                 = "AppSubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["172.21.39.128/26"]
}

#AppGW Subnet may require a larger network block (CIDR) such as /24, reconfig AppGW subnet to accomodate this for AppGW scaling. 
#For testing purpose a smaller CIDR /26 is fine. 
resource "azurerm_subnet" "gateway" {
  name                                          = "appgateway"
  resource_group_name                           = azurerm_resource_group.azurg.name
  virtual_network_name                          = azurerm_virtual_network.azuvnet.name
  address_prefixes                              = ["172.21.39.192/26"]
  enforce_private_link_service_network_policies = true
}


/*
resource "azurerm_subnet_route_table_association" "azurtassocapp" {
  subnet_id      = azurerm_subnet.azusubnetapp.id
  route_table_id = azurerm_route_table.azurt.id
} 
*/


/*
resource "azurerm_subnet_route_table_association" "azurtassocdb" {
  subnet_id      = azurerm_subnet.azusubnetdb.id
  route_table_id = azurerm_route_table.azurt.id
}
*/

#Log Analytics (Azure Monitoing)
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "cc-log-ana-wkspace"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

/*
#DDoS Protection Plan

resource "azurerm_network_ddos_protection_plan" "example" {
  name                = "ddos-protection-plan"
  resource_group_name  = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
}
*/


# Public IP for Azure Firewall
resource "azurerm_public_ip" "azufwpip" {
  name                = "azureFirewalls-pip"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "CC_MVP"
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
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
}


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
    destination_port_ranges     = ["80","443","22"]
    #source_address_prefix      = "*"
    source_address_prefix      =  "*"
    destination_address_prefix = "*"
    #destination_address_prefixes = [ "10.29.1.0/30","10.29.2.0/27"] #Outbound to App & DB subnets
    #Note: optimize NSG rules for production, allow only required IP/port ranges 
  }

  tags = {
    environment = "CC_MVP"
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
    name                       = "app1"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80","443"]
    #source_address_prefix      = "*"
    #destination_address_prefix = "*"
    #source_address_prefix      =  "*"  #should be replaced with Application gateway or Load Balancer public IP when configured plus
    # Bastion Subnet range, Note: optimize NSG rules for production, allow only required IP/port ranges 
    source_address_prefixes    = ["172.21.39.192/26","172.21.39.64/29"] 
    destination_address_prefixes = ["172.21.39.128/26"]  #outbound to DB subnet
  }

  tags = {
    environment = "CC_MVP"
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
    name                       = "db1"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["5432","1433","4022","1434","3306"]
    #source_address_prefix      = "*"
    #destination_address_prefix = "*"
    source_address_prefixes      =  [ "172.21.39.64/29","172.21.39.128/26"]  
    #Inbound from App subnet and/or  loadbalancer fqdn if configured with HA
    ##Note: optimize NSG rules for production, allow only required IP/port ranges 
    #Note: DB NSG rules should allow App subnet range only + optionally from Baastion securely for admins, and
    # this should be highly restrictive
    destination_address_prefixes = ["172.21.39.96/28"]  
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

/*
The confidential computing VMs cannot be provisioned with terraform as of 07/12/2022, and per Microsoft CVM provisioning will be available 
post GA of CVMs (V5) end of July. Use "azurerm_resource_group_template_deployment" as a workaround. Network Interface Card (NIC) for VMs can be
pre-created and referenced or created during VM deployment
*/


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
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azunicjb" {
  network_interface_id      = azurerm_network_interface.azunicjb.id
  network_security_group_id = azurerm_network_security_group.azunsgjb.id
}

# Nic for App Server (CX Engine)
resource "azurerm_network_interface" "azuniccxengine" {
  name                = "AppCxEngineNIC"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetapp.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azuniccxengine" {
  network_interface_id      = azurerm_network_interface.azuniccxengine.id
  network_security_group_id = azurerm_network_security_group.azunsgapp.id
}


# Nic for App Server (Active MQ VM)
resource "azurerm_network_interface" "azunicactivemq" {
  name                = "AppActiveMQNIC"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetapp.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azunicactivemq" {
  network_interface_id      = azurerm_network_interface.azunicactivemq.id
  network_security_group_id = azurerm_network_security_group.azunsgapp.id
}

# Nic for App Server (CX manager VM)
resource "azurerm_network_interface" "azuniccxmgr" {
  name                = "AppCXMgrNIC"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetapp.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azuniccxmgr" {
  network_interface_id      = azurerm_network_interface.azuniccxmgr.id
  network_security_group_id = azurerm_network_security_group.azunsgapp.id
}


# Nic1 for DB Server1 (Windows SQL Server VM)
resource "azurerm_network_interface" "azunicdbvm1" {
  name                = "DBServerNIC1"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.azusubnetdb.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}

resource "azurerm_network_interface_security_group_association" "azunicdbvm1" {
  network_interface_id      = azurerm_network_interface.azunicdbvm1.id
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
    environment = "CC_MVP"
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
  public_key          = file("~/.ssh/futureai_sast_key_4096.pub")
}

#Create cloud-init cloudconfig 

data "template_file" "cloudconfig" {
  template = "${file("${var.cloudconfig_file}")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}

#USWEST region will not provide VM ScaleSets or AZs for Application HA as of mid-june 2022, use Availability Set instead.

resource "azurerm_availability_set" "cxaset" {
  name                = "az-set-1"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name

  tags = {
    environment = "MVP"
  }
}

/*
The confidential computing VMs cannot be provisioned with terraform as of 07/12/2022, and per Microsoft CVM provisioning will be available 
post GA of CVMs (V5) end of July. Use "azurerm_resource_group_template_deployment" as a workaround. 
Use ARM templates with terraform located in deployment/cvm/templates/vms/ sub-directory of repo
*/

# Virtual Machine Provisioning block: start
/*
# Bastion VM with template
resource "azurerm_linux_virtual_machine" "bastionvm" {
  name                  = "Bastion"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  #size                            = "Standard_DC4s_v3"
  #size                            = "Standard_DC4as_v5"
  size                  = "Standard_D4_v5"
  admin_username        = "adminuser"
  network_interface_ids = ["${azurerm_network_interface.azunicjb.id}"]
  #template_body = file("arm/template.jsonarm/bastion_cc_vm.json")
  # OR use template_body below 
  #template_body = <<DEPLOY
      #Json ARM template file content 
  #DEPLOY
}
*/

/*
# Bastion VM 

resource "azurerm_linux_virtual_machine" "bastionvm" {
  name                  = "Bastion"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  #size                            = "Standard_DC4s_v3"
  #size                  = "Standard_D4_v5"
  size                  = "Standard_D2_v3"
  #admin_username        = "adminuser"
  admin_username        = var.appadminUsername
  network_interface_ids = ["${azurerm_network_interface.azunicjb.id}"]
  custom_data          = "${data.template_cloudinit_config.config.rendered}"

  admin_ssh_key {
    username = var.appadminUsername
    #public_key = file("~/.ssh/id_rsa.pub")
    public_key = azurerm_ssh_public_key.sshkey.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    #sku       = "20.04-LTS"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }

  depends_on = [azurerm_network_interface_security_group_association.azunicjb]
}


# App Server VM (ActiveMQ)

resource "azurerm_linux_virtual_machine" "mqvmappvm" {
  name                  = "MQAppVM1"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  #size                 = "Standard_DC4s_v3"
  #size                  = "Standard_D4_v5"
  size                  = "Standard_D2_v3"
  #admin_username        = "appadmin"
  admin_username        = var.appadminUsername
  network_interface_ids = ["${azurerm_network_interface.azunicactivemq.id}"]
  custom_data          = "${data.template_cloudinit_config.config.rendered}"

  admin_ssh_key {
    #username = "appadmin"
    #public_key = file("~/.ssh/id_rsa.pub") #Use only pub key from bastion, Should be restricted from everywhere else. Once security hardened, restrict Access
    username = var.appadminUsername
    public_key = azurerm_ssh_public_key.sshkey.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    #sku       = "20.04-LTS"
    sku       = "18.04-LTS" 
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }

  depends_on = [azurerm_network_interface_security_group_association.azunicactivemq]
}

# App Server VM (CXEngine)

resource "azurerm_linux_virtual_machine" "cxenginevm" {
  name                  = "CX-Engine-VM"
  resource_group_name   = azurerm_resource_group.azurg.name
  location              = azurerm_resource_group.azurg.location
  #size                 = "Standard_DC8s_v3"
  #size                  = "Standard_D8_v5"
  size                  = "Standard_D2_v3"
  #admin_username        = "appadmin"
  admin_username        = var.appadminUsername
  network_interface_ids = ["${azurerm_network_interface.azuniccxengine.id}"]
  custom_data          = "${data.template_cloudinit_config.config.rendered}"

  admin_ssh_key {
    #username = "appadmin"
    #public_key = file("~/.ssh/id_rsa.pub") #Use only pub key from bastion, Should be restricted from everywhere else. Once security hardened, restrict Access
    username = var.appadminUsername
    public_key = azurerm_ssh_public_key.sshkey.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    #sku       = "20.04-LTS"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
  depends_on = [azurerm_network_interface_security_group_association.azuniccxengine]
}

# Windows Server VM (CX Manager ) 

resource "azurerm_windows_virtual_machine" "WinVMMgrServer" {
  name                = "Win-CX-Mgr-VM"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  #size                 = "Standard_DC8s_v3"
  #size                  = "Standard_D8_v5"
  size                  = "Standard_D2_v3"
  admin_username = var.appadminUsername
  admin_password = var.appadminPassword
  network_interface_ids = [
    azurerm_network_interface.azuniccxmgr.id,
  ]
  custom_data          = "${data.template_cloudinit_config.config.rendered}"

  os_disk {
    name              = "CXMgr-Server-OSDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"    
  }


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
  depends_on = [azurerm_network_interface_security_group_association.azuniccxmgr]
}

# Windows Server VM (SQL Server DB) 
resource "azurerm_windows_virtual_machine" "WinVMDBServer" {
  name                = "Win-CX-SQL-VM"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  #size                 = "Standard_DC8s_v3"
  #size                  = "Standard_D8_v5"
  size                  = "Standard_D2_v3"
  admin_username = var.dbadminUsername
  admin_password = var.dbadminPassword
  network_interface_ids = [
    azurerm_network_interface.azunicdbvm1.id, 
    azurerm_network_interface.azunicdbvm2.id,
  ]
  custom_data          = "${data.template_cloudinit_config.config.rendered}"

  os_disk {
    name              = "SQL-Server-OSDisk1"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"    
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
  }
  depends_on = [
    azurerm_network_interface_security_group_association.azunicdbvm1, 
    azurerm_network_interface_security_group_association.azunicdbvm2,
    ]
}

*/
# Virtual Machine Provisioning block: end

/*
Azure Firewall is moved to a sub-directory under deployment/azureFW and can either be deployed as part of landing zone or a seperate 
add on deployment
*/

/*
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
      #"10.29.0.0/29",
      "*",
    ]

    target_fqdns = [
      "*.microsoft.com","*.future.ai.com","*.future.ainet.com"
    ]

    protocol {
      port = "443"
      type = "Https"
     }
  }
}

# Azure Firewall Network Rule
resource "azurerm_firewall_network_rule_collection" "azufwnetr1" {
  name                = "fwrulecollection"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = azurerm_resource_group.azurg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "netRc1"

    source_addresses = [
      #"10.29.0.0/29",
      "*",
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
  name                = "natrule1"
  azure_firewall_name = azurerm_firewall.azufw.name
  resource_group_name = azurerm_resource_group.azurg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "natrule1"

    source_addresses = [
      #"10.29.0.0/19",
      "*",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      azurerm_public_ip.azufwpip.ip_address
    ]

    translated_port = 53

    translated_address = "8.8.8.8"
    #translated_address = "192.168.76.180"
    #translated_address = ["172.23.241.180","172.23.241.181"]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}
*/

#Disk Encription Set

data "azurerm_client_config" "current" {}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}


resource "azurerm_key_vault" "kvaultcc6" {
  name                        = "des-sast-keyvault-cc6"
  location                    = azurerm_resource_group.azurg.location
  resource_group_name         = azurerm_resource_group.azurg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true

    access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
  }
}

#Azure KeyVault Certificate
resource "azurerm_key_vault_certificate" "azrkvcert" {
  name         = "kv-cert6"
  key_vault_id = azurerm_key_vault.kvaultcc6.id

  certificate {
    contents = filebase64("appGWCert/appgwcertFUTURE.pfx")
    password = var.sslExportPasswd
  }
}

resource "azurerm_key_vault_key" "kvkey5" {
  name         = "des-keyvault-key6"
  key_vault_id = azurerm_key_vault.kvaultcc6.id
  key_type     = "RSA"
  key_size     = 2048

  depends_on = [
    azurerm_key_vault_access_policy.kv-access-user-2
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
  key_vault_key_id    = azurerm_key_vault_key.kvkey5.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "encrypt-disk" {
  key_vault_id = azurerm_key_vault.kvaultcc6.id

  tenant_id = azurerm_disk_encryption_set.encryptset.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.encryptset.identity.0.principal_id
  /*
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ] */

  certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
}

resource "azurerm_key_vault_access_policy" "kv-access-user-2" {
  key_vault_id = azurerm_key_vault.kvaultcc6.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  /*
  key_permissions = [
    "Get",
    "Create",
    "Delete"
  ] */
  certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
}

/*
Azure Managed Hardware Security Module (Azure MHSM) is moved to a sub-directory under deployment/hsm and can either be deployed as 
part of landing zone or a seperate add on deployment
*/

#Azure Managed Hardware Security Module (Azure MHSM) block start

#data "azurerm_client_config" "current" {}
/*
resource "azurerm_key_vault_managed_hardware_security_module" "cckvmhsm" {
  name                       = "ccKVHsm1"
  resource_group_name        = azurerm_resource_group.azurg.name
  location                   = azurerm_resource_group.azurg.location
  sku_name                   = "Standard_B1"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  admin_object_ids           = [data.azurerm_client_config.current.object_id]

  tags = {
    environment = "CC_MVP"
    owner       = "skondla@me.com"
    cost_center_name  = "future.ai"
    cost_center_code  = "23745"
  }
}
*/
#Azure Managed Hardware Security Module (Azure MHSM) block end

/*
Virtual WAN, VPN Gateway within a Virtual Hub, which enables Site-to-Site communication are moved to a sub-directory under deployment/vpnGW 
and can either be deployed as part of landing zone or a seperate add on deployment. Comment the section below if this is required part of cloud landing zone
*/

/*
##VPN gateway subnet start
#Virtual WAN, VPN Gateway within a Virtual Hub, which enables Site-to-Site communication

resource "azurerm_virtual_wan" "vwan" {
  name                = "cc-vwan1"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "cc-hub1"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "172.21.39.0/24"
}


resource "azurerm_vpn_gateway" "vpngw1" {
  name                = "cc-vpngw1"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name
  virtual_hub_id      = azurerm_virtual_hub.vhub.id
}

##VPN gateway subnet end
*/



/*
Azure Application gateway is moved to a sub-directory under deployment/appGW and can either be deployed as 
part of landing zone or a seperate add on deployment or replaced with load lalancer (deployment/loadBalancer) depending on
L7/L4 traffic requirements and HTTPS or HTTP with URL based routing, TLS termination fuctionality
*/

#Application gateway block (start)
/*
resource "azurerm_public_ip" "agwpip" {
  #name                = "${var.prefix}-ip"
  name                = "AppGateway-pip"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  private_link_configuration_name        = "private_link"
  private_frontend_ip_configuration_name = "private"
}

resource "azurerm_application_gateway" "appgw" {
  #name                = "${var.prefix}-gateway"
  name                = "application-gateway"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  sku {
    #name     = "Standard_Small"
    #tier     = "Standard"
    #name     = "Standard_Medium"
    #tier     = "Standard"
    name      = "WAF_v2" # Values: [Standard_Small Standard_Medium Standard_Large Standard_v2 WAF_Large WAF_Medium WAF_v2]
    tier      = "WAF_v2" #Values: [Standard Standard_v2 WAF WAF_v2]
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway"
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_port {
    name = "frontend"
    port = 80
  }

 
  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.agwpip.id
  }
  
  frontend_ip_configuration {
    name                            = local.private_frontend_ip_configuration_name
    subnet_id                       = azurerm_subnet.gateway.id
    private_ip_address_allocation   = "Static"
    private_ip_address              = "172.21.39.198"
    private_link_configuration_name = local.private_link_configuration_name
  } 
  

  private_link_configuration {
    name = local.private_link_configuration_name
    ip_configuration {
      name                          = "primary"
      subnet_id                     = azurerm_subnet.gateway.id
      private_ip_address_allocation = "Dynamic"
      primary                       = true
    }
  }

  # A backend pool routes request to backend servers, which serve the request.
  # Can create different backend pools for different types of requests

  backend_address_pool {
    name = "backend1"
    #ip_addresses = ["10.29.2.5", "10.29.2.6"  ]
  }
  

  backend_http_settings {
    name                  = "be_http_settings1"
    #cookie_based_affinity = "Disabled" #Possible Values: Enabled, Disabled
    cookie_based_affinity = var.cookie_based_affinity
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }
  
    backend_http_settings {
    name                  = "be_https_settings2"
    #cookie_based_affinity = "Disabled" #Possible Values: Enabled, Disabled
    cookie_based_affinity = var.cookie_based_affinity
    port                  = 443
    protocol              = "Https"
    request_timeout       = 30
  } 
  

  ssl_certificate {
     name     = "appGWCert"
     data     = "${filebase64("appGWCert/appgwcertFUTURE.pfx")}"
     password = var.sslExportPasswd
  }
  http_listener {
    name                           = "listener1"
    frontend_ip_configuration_name = "public"
    frontend_port_name             = "frontend"
    protocol                       = "Http"
    ssl_certificate_name           = "appGWCert"
  }
  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "listener1"
    backend_address_pool_name  = "backend1"
    backend_http_settings_name = "be_http_settings1"
  }

  waf_configuration {
    enabled                  = var.waf_enabled
    firewall_mode            = coalesce(var.waf_configuration != null ? var.waf_configuration.firewall_mode : null, "Prevention")
    rule_set_type            = coalesce(var.waf_configuration != null ? var.waf_configuration.rule_set_type : null, "OWASP")
    rule_set_version         = coalesce(var.waf_configuration != null ? var.waf_configuration.rule_set_version : null, "3.0")
    file_upload_limit_mb     = coalesce(var.waf_configuration != null ? var.waf_configuration.file_upload_limit_mb : null, 100)
    max_request_body_size_kb = coalesce(var.waf_configuration != null ? var.waf_configuration.max_request_body_size_kb : null, 128)
  }

}

*/
/*
resource "azurerm_private_link_service" "pvlink" {
  name                = "${var.prefix}-pvlink"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name

  nat_ip_configuration {
    name      = azurerm_application_gateway.appgw.frontend_ip_configuration.1.name
    primary   = true
    subnet_id = azurerm_subnet.gateway.id
  }

  appgw_frontend_ip_configuration_ids = [
    azurerm_application_gateway.appgw.frontend_ip_configuration.1.id,
  ]
} 

resource "azurerm_private_endpoint" "pe" {
  name                = "${var.prefix}-pe"
  location            = azurerm_resource_group.azurg.location
  resource_group_name = azurerm_resource_group.azurg.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "cc-appgateway-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_private_link_service.pvlink.id
    subresource_names = [
      local.private_frontend_ip_configuration_name,
    ]
  }
}
*/
#Application gateway block (end)

#Private DNS Zone

resource "azurerm_private_dns_zone" "pdnszone" {
  name                = "pdsea.future.ainet.com"
  resource_group_name = azurerm_resource_group.azurg.name
}

#Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "vnetlink1" {
  name                  = "vnetlink1"
  resource_group_name   = azurerm_resource_group.azurg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdnszone.name
  virtual_network_id    = azurerm_virtual_network.azuvnet.id
}

#Add A record to Private DNS Zone

resource "azurerm_private_dns_a_record" "arecord" {
  name                = "appgw-backend1-servers"
  zone_name           = azurerm_private_dns_zone.pdnszone.name
  resource_group_name = azurerm_resource_group.azurg.name
  ttl                 = 3600
  records             = ["172.21.39.69","172.21.39.70"]
}

/*
Vnet Gateway is moved to a sub-directory under deployment/vNetGW 
and can either be deployed as part of landing zone or a seperate add on deployment. 
Comment the section below if this is required part of cloud landing zone
*/

/*
#VNet gateway (Vnet to Vnet, Site to Site VPN)

##VPN gateway subnet start

resource "azurerm_subnet" "azusubnetgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.29.10.0/27"]
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
  sku      = "Basic" #SKUs: Basic (100 Mbps), VpnGw1 (650 Mbps) , VpnGw2 (1 Gbps), VpnGw3 (1.25 Gbps), VpnGw4 (5 Gbps) ,VpnGw5 (10 Gbps)  

  ip_configuration {
     name                          = "vnetGatewayConfig"
     public_ip_address_id          = azurerm_public_ip.azugwpip.id
     private_ip_address_allocation = "Dynamic"
     subnet_id                     = azurerm_subnet.azusubnetgw.id
  }
  #VPN Client Config (start)

  vpn_client_configuration {
    address_space = ["172.21.39.0/24"]
    root_certificate {
      name = "DigiCert-Federated-ID-Root-CA"
      public_cert_data = <<EOF
MIIDuzCCAqOgAwIBAgIQCHTZWCM+IlfFIRXIvyKSrjANBgkqhkiG9w0BAQsFADBn
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSYwJAYDVQQDEx1EaWdpQ2VydCBGZWRlcmF0ZWQgSUQg
Um9vdCBDQTAeFw0xMzAxMTUxMjAwMDBaFw0zMzAxMTUxMjAwMDBaMGcxCzAJBgNV
BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
Y2VydC5jb20xJjAkBgNVBAMTHURpZ2lDZXJ0IEZlZGVyYXRlZCBJRCBSb290IENB
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvAEB4pcCqnNNOWE6Ur5j
QPUH+1y1F9KdHTRSza6k5iDlXq1kGS1qAkuKtw9JsiNRrjltmFnzMZRBbX8Tlfl8
zAhBmb6dDduDGED01kBsTkgywYPxXVTKec0WxYEEF0oMn4wSYNl0lt2eJAKHXjNf
GTwiibdP8CUR2ghSM2sUTI8Nt1Omfc4SMHhGhYD64uJMbX98THQ/4LMGuYegou+d
GTiahfHtjn7AboSEknwAMJHCh5RlYZZ6B1O4QbKJ+34Q0eKgnI3X6Vc9u0zf6DH8
Dk+4zQDYRRTqTnVO3VT8jzqDlCRuNtq6YvryOWN74/dq8LQhUnXHvFyrsdMaE1X2
DwIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNV
HQ4EFgQUGRdkFnbGt1EWjKwbUne+5OaZvRYwHwYDVR0jBBgwFoAUGRdkFnbGt1EW
jKwbUne+5OaZvRYwDQYJKoZIhvcNAQELBQADggEBAHcqsHkrjpESqfuVTRiptJfP
9JbdtWqRTmOf6uJi2c8YVqI6XlKXsD8C1dUUaaHKLUJzvKiazibVuBwMIT84AyqR
QELn3e0BtgEymEygMU569b01ZPxoFSnNXc7qDZBDef8WfqAV/sxkTi8L9BkmFYfL
uGLOhRJOFprPdoDIUBB+tmCl3oDcBy3vnUeOEioz8zAkprcb3GHwHAK+vHmmfgcn
WsfMLH4JCLa/tRYL+Rw/N3ybCkDp00s0WUZ+AoDywSl0Q/ZEnNY0MsFiw6LyIdbq
M/s/1JRtO3bDSzD9TazRVzn2oBqzSa8VgIo5C1nOnoAKJTlsClJKvIhnRlaLQqk=
EOF
    }
    revoked_certificate {
      name       = "Verizon-Global-Root-CA"
      thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B1"
    }
  }
}  
  #VPN Client config (end)  

##VPN gateway  end
*/