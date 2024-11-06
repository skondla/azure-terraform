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


# azure-sql (sqlserver) - in progress
 
To provision Azure sqlserverql database with geo-redundancy, use this sample. Make sure "Landing zone has already been provisioned"

    cd deployment/database/sqlserver/alwaysEncripted
    terraform init
    terraform plan --out plan-pgsql
    terraform apply "plan-alwaysEncripted-sqlsrv"

# Proposed Architecture Diagram
![imagename](https://docs.f5net.com/download/attachments/722365217/Checkmarx_Arch_Single-AZ-Azure-1.png?version=5&modificationDate=1648656065000&api=v2)
