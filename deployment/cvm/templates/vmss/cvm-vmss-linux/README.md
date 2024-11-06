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

# azure-vmss (Virtual Machine Scale Sets)

    Azure virtual machine scale sets let you create and manage a group of load balanced VMs. The number of VM instances can automatically increase or decrease in response to demand or a defined schedule. Scale sets provide the following key benefits:

    1.  Easy to create and manage multiple VMs
    2.  Provides high availability and application resiliency by distributing VMs across availability zones or fault domains
    3.  Allows your application to automatically scale as resource demand changes
    4.  Works at large-scale

    Note: Currently customer managed key for disk encryption is not supported for VM Scale sets

<!--
    Error: creating Linux Virtual Machine Scale Set: (Name "cvm-vmss-lnx" / Resource Group 
    "chkmarx-conf-compute-mvp"): compute.VirtualMachineScaleSetsClient#CreateOrUpdate: 
    Failure sending request: StatusCode=400 -- Original Error: Code="BadRequest" 
    Message="Virtual Machines Scale Sets do not allow setting managedDisk.securityProfile.diskEncryptionSet."

    Error: waiting for creation of Linux Virtual Machine Scale Set: (Name "cvm-vmss-lnx" / Resource Group 
    "chkmarx-conf-compute-mvp"): Code="BadRequest" Message="Encryption Type ConfidentialVmEncryptedWithCustomerKey
     is not supported for server side encryption with customer managed key.  
     Target: '/subscriptions/23583f43-xxxx-abcd-kstr-yyyyyyyyy/resourceGroups/chkmarx-conf-compute-mvp/
     providers/Microsoft.Compute/disks/cvm-vmss-lnx_cvm-vmss-lnx_0_OsDisk_1_d4cac81b5b9742cdbc85738b9240fef3'."
-->

# Deploy
    cd deployment/cvm/templates/vmss/cvm-vmss-linux
    source setSenstiveData.sh
    terraform init
    terraform plan --out cvm-vmss-linux-plan
    terraform apply "cvm-vmss-linux-plan"


