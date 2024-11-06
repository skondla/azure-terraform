#Create a Terraform configuration with a backend configuration block

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n cc-appgw-tfstate --account-name "confcomptfstateokweo8hp" 
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
        container_name       = "cc-appgw-tfstate"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}

# Azure Application Gateway module
data "azurerm_resource_group" "appgwrg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "appgwnet" {
  name = var.virtual_network
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = var.appgw_subnet_id
  virtual_network_name = var.virtual_network
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "endpointsubnet" {
  name                 = var.endpoint_subnet_id
  virtual_network_name = var.virtual_network
  resource_group_name  = var.resource_group_name
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.appgwnet.id
}

#Application gateway block (start)
resource "azurerm_public_ip" "agwpip" {
  #name                = "${var.prefix}-ip"
  name                = "AppGateway-pip"
  location            = data.azurerm_resource_group.appgwrg.location
  resource_group_name = data.azurerm_resource_group.appgwrg.name
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
  resource_group_name = data.azurerm_resource_group.appgwrg.name
  location            = data.azurerm_resource_group.appgwrg.location

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
    subnet_id = data.azurerm_subnet.appgwsubnet.id
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
    subnet_id                       = data.azurerm_subnet.appgwsubnet.id
    private_ip_address_allocation   = "Static"
    private_ip_address              = "172.21.39.198"
    private_link_configuration_name = local.private_link_configuration_name
  } 
  

  private_link_configuration {
    name = local.private_link_configuration_name
    ip_configuration {
      name                          = "primary"
      subnet_id                     = data.azurerm_subnet.appgwsubnet.id
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

#Application gateway block (end)

#Private DNS Zone

resource "azurerm_private_dns_zone" "pdnszone" {
  name                = "pdsea.future.ainet.com"
  resource_group_name = data.azurerm_resource_group.appgwrg.name
}

#Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "vnetlink1" {
  name                  = "vnetlink1"
  resource_group_name   = data.azurerm_resource_group.appgwrg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdnszone.name
  virtual_network_id    = data.azurerm_virtual_network.appgwnet.id
}

#Add A record to Private DNS Zone

resource "azurerm_private_dns_a_record" "arecord" {
  name                = "appgw-backend1-servers"
  zone_name           = azurerm_private_dns_zone.pdnszone.name
  resource_group_name = data.azurerm_resource_group.appgwrg.name
  ttl                 = 3600
  records             = ["172.21.39.69","172.21.39.70"]
}
