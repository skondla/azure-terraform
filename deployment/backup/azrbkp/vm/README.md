# Checkmarx SAST for code scanning

Checkmarx SAST a source code analysis solution that provides tools for identifying, tracking, repairing technical and logical flaws in the source code such as security vulnerabilities, compliance issues, and business logic problems. Without needing to build or compile a project's source code. SAST provides scan results either as static reports, or in an interactive interface that enables tracking runtime behavior.

Checkmarx security requirements in Confidential Computing environments:

Given Checkmarx push/pull entire source code into the platform for scans, the security around dealing with sensitive data, IPs, encryption keys in the cloud should meet following minimum requirements


# Before provisioning 

Consider using remote terraform state 

    cd deployment/remoteState
    terraform init
    terraform plan --out remote-state-plan
    terraform apply "remote-state-plan"


# azure-vms

The confidential computing VMs cannot be provisioned with terraform as of MVP deployment, and per Microsoft CVM provisioning will be available post GA of CVMs (V5) end of July. Use "azurerm_resource_group_template_deployment" as a workaround

    cd deployment/cvm/arm/templates/vms/examples/linux/1
    terraform init
    terraform plan --out build-cvm-plan
    terraform apply "build-cvm-plan"

# azure-backup for VMs

The confidential computing VMs are not compatible with Azure Backup or Site disaster recovery as of 06/15/2022, however this feature will be released for CVMs post GA of version 5 (CVM V5)(end of July or August, 2022 )

    cd deployment/backup/azrbkp/vm
    terraform init
    terraform plan --out plan-vm-backup
    terraform apply "plan-vm-backup"