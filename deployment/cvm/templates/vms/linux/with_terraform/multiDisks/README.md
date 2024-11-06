# Checkmarx SAST for code scanning

Checkmarx SAST a source code analysis solution that provides tools for identifying, tracking, repairing technical and logical flaws in the source code such as security vulnerabilities, compliance issues, and business logic problems. Without needing to build or compile a project's source code. SAST provides scan results either as static reports, or in an interactive interface that enables tracking runtime behavior.

Checkmarx security requirements in Confidential Computing environments:

Given Checkmarx push/pull entire source code into the platform for scans, the security around dealing with sensitive data, IPs, encryption keys in the cloud should meet following minimum requirements


# Before provisioning (1a)

Consider using remote terraform state 

    cd deployment/remoteState
    terraform init
    terraform plan --out remote-state-plan
    terraform apply "remote-state-plan"

# Before provisioning (1b)

Make sure vnet, subnet, NSG and other common resources are provisioned

# azure-vms

The confidential computing VMs cannot be provisioned with terraform as of MVP deployment, and per Microsoft CVM provisioning will be available post GA of CVMs (V5) end of July. Use "azurerm_resource_group_template_deployment" as a workaround

    cd deployment/cvm/templates/vms/linux/with_terraform/multiDisks
    source setSenstiveData.sh
    cp parameters.json parameters.json.bkup
    
    # Replace pubkey in json file with actual 4096 bit encrypted pubkey

     "adminPublicKey": {
            "value": "'($TF_VAR_pubKey)'"
     }

    jq '.adminPublicKey.value=env.TF_VAR_pubKey' parameters.json > tmp.json && mv tmp.json parameters.json
    terraform init
    terraform plan --out build-cvm-plan
    terraform apply "build-cvm-plan"

# Partitioning second storage disk for data
As a best practice to provision at least 2 disks, and seperate OS binaries/configuration from application software and data 


    1. After successful provision of CVM use "partDisk.sh" to create partition, format it to ext4 linux extention, mount it
    2. cd deployment/cvm/templates/vms/linux/with_terraform/multiDisks
    3. bash partDisk.sh
    
    4. To remove partition and re-use it - use "unpartDisk.sh"
    5. cd deployment/cvm/templates/vms/linux/with_terraform/multiDisks
    6. unpartDisk.sh


