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

Make sure the resource group  is already created before availability set is being deployed.

# azure availability sets


This step can also be created while creating Virtual machines in a single zone with fault tolerance and compute redundancy

# Availability sets:  
    
An availability set is a logical grouping of VMs that allows Azure to understand how your application is built to provide for redundancy and availability. It is recommended that two or more VMs are created within an availability set to provide for a highly available application and to meet the 99.95% Azure SLA. There is no cost for the Availability Set itself, you only pay for each VM instance that you create.

# Deploy
    cd deployment/availability-set
    terraform init
    terraform plan --out availability-set-plan
    terraform apply "availability-set-plan"


