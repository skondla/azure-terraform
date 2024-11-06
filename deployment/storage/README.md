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

# Network Attached Storage (NAS) or Network File System (NFS) Options

Azure provides two types of NAS for any clustering, shared storage an application needs. 

1.  Azure Storage (Azure Files)
        This offering is part of Azure Storage accout in which you can choose file share option as NAS solution and mount the file share both on Linux and Windows.
        Fully managed file shares in the cloud that are accessible via the industry-standard SMB and NFS protocols. Azure Files shares can be mounted concurrently by cloud or on-premises deployments of Windows, Linux, and macOS. Azure Files shares can also be cached on Windows Servers with Azure File Sync for fast access near where the data is being used. 
   
2.  Azure NetApp files
        Azure NetApp Files is widely used as the underlying shared file-storage service in various scenarios. These include migration (lift and shift) of POSIX-compliant Linux and Windows applications, SAP HANA, databases, high-performance compute (HPC) infrastructure and apps, and enterprise web applications.
   
3.  Before you mount the NAS volume, make sure you have provisioned a Linux and/or Windows VM(s)

4.  The following step creates a storage account with customer managed keys stored in Azure Key Vault. Remember large_file_share_enabled="true" will support file shares maximum size up to 100 TiB and cannot be changed once the storage account is created. Consider using this option when NAS storage capacity requirement is not know, otherwise it will be limited to a maximum size of 5 TiB

        cd deployment/storage/encryption/azrstorage_akv
        terraform init
        terraform plan --out storage-account-encrypt-plan
        terraform apply "storage-account-encrypt-plan"
    
5.  The following step creates a File share Volume 

        cd deployment/storage/encryption/azrstorage_akv/fileShare
        terraform init
        terraform plan --out file-share-encrypt-plan
        terraform apply "file-share-encrypt-plan"
    
6.  The following step creates an Azure NetApp Files. Encryption not tested with this option, which requires 1) Kerberos, AD integration setup 2) This solution pre-allocates a minimum storage size 4 TiB and charged at per GB/month on all 4 TiB size which is not as cost effective as file share.

        cd deployment/storage/nfs/netapp
        bash setupAZRNetAPPFiles.sh

