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


# azure-landing-zone1

This template can be used for creating AZR resource group, Vnet and underlying infrastructure with Virtual Network such as subnets, NSG inbound/outbound rules, AZR FW, AppGW, VWAN, Virtual Hub etc.

In Order to successfully run terraform deployment follow the steps below

   Step1: To read keys/users/password from local directory without exposing it to password to terraform varibles

    source setSenstiveData.sh
   Step2: generate self-signed SSL certificate(s) to export it to application gateway

    source createSelfSignedSSLCerts.sh

   Step3: run terraform terraform init to make sure all missing packages/libs are downloaded

    terraform init
   Step4: run terraform plan --out plan1 create a plan to deploy

    terraform plan --out plan1
   Step5: run terraform apply "plan1" to create infrastructure

    terraform apply "plan1"

# Load Balancer

Use the sample terraform script to provision L4 Azure Load Balancer

    cd deployment/loadBalancer
    terraform init
    terraform plan --out plan-lb
    terraform apply "plan-lb"

# azure-vms

The confidential computing VMs cannot be provisioned with terraform as of MVP deployment, and per Microsoft CVM provisioning will be available post GA of CVMs (V5) end of July. Use "azurerm_resource_group_template_deployment" as a workaround

    cd deployment/cvm/arm/templates/vms/examples/linux/1
    terraform init
    terraform plan --out build-cvm-plan
    terraform apply "build-cvm-plan"

# azure-backup for VMs

The confidential computing VMs are not compatible with Azure Backup or Site disaster recovery as of 06/15/2022, however this feature will be released for CVMs post GA of version 5 (CVM V5)(end of July or August, 2022 )

    cd deployment/backup/vm
    terraform init
    terraform plan --out plan-vm-backup
    terraform apply "plan-vm-backup"
# azure-sql
 
To provision Azure SQLServer database with geo-redundancy, use this sample

    cd deployment/database/sqlserver
    terraform init
    terraform plan --out plan-sqlsrv
    terraform apply "plan-sqlsrv"

# Proposed Architecture Diagram
![Alt text](../architecture/chkmrx-ha-multi-zone.png)
