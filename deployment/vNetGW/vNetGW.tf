#Create a Terraform configuration with a backend configuration block

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n cc-vnetgw-tfstate --account-name "confcomptfstateokweo8hp" 
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
        container_name       = "cc-vnetgw-tfstate"
        key                  = "terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}

# Azure Application Gateway module
data "azurerm_resource_group" "vnetgwrg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnetgwnet" {
  name = var.virtual_network
  resource_group_name  = var.resource_group_name
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.vnetgwnet.id
}

#VNet gateway (Vnet to Vnet, Site to Site VPN)

##VPN gateway subnet start
/*
Check correct network address space allocation (CIDR block) when planning subnetting and make sure they won't collide with 
other subnet range
*/
resource "azurerm_subnet" "azusubnetgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = data.azurerm_resource_group.vnetgwrg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["172.21.39.132/27"]
}

resource "azurerm_public_ip" "azugwpip" {
  name                = "gateway-pip"
  location            = data.azurerm_resource_group.vnetgwrg.location
  resource_group_name = data.azurerm_resource_group.vnetgwrg.name
  allocation_method   = "Dynamic"
}


resource "azurerm_virtual_network_gateway" "azuvnetgw" {
  name                = "VNetGateway1"
  location            = data.azurerm_resource_group.vnetgwrg.location
  resource_group_name = data.azurerm_resource_group.vnetgwrg.name

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