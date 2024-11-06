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


# azure-bastion-svc

Azure Bastion Service (Azure Managed Service) and Bastion Host (VM) are two different resources. And "AzureBastionSubnet" requires a larger a large network address block (/26 or greater) and highly scalable, however waste network space. Use Bastion Host VM as a normal VM deployment and harden security and ssh (PKI)

    cd deployment/bastionService
    terraform init
    terraform plan --out bastion-svc-plan
    terraform apply "bastion-svc-plan"

