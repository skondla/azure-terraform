#Create a Terraform configuration with a backend configuration block
resource "null_resource" "storage-container" {
  provisioner "local-exec" {
    command = <<EOT
      az storage container create -n "cvm-multi-disk-tfstate" --account-name "confcomptfstateokweo8hp"
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
        container_name       = "cvm-multi-disk-tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group_template_deployment" "ccvm" {
  count               = var.node_count
  name                = "${var.prefix}-${var.node_type}-${count.index + 1}"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = file("./template.json")
  parameters_content  = file("./parameters.json")
  tags = {
    application        = var.application
    cxsast_node_prefix = var.prefix
    cxsast_node_type   = var.node_type
    owner              = var.owner
    cost_center_name   = var.cost_center_name
    cost_center_code   = var.cost_center_code
  }
}
