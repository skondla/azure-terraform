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

Make sure you have already provisioned Linux confidential VM 

# Microsoft Azure Attestation - Generate Report

    cd deployment/cvm/attestation/linux/c++/report
    scp -i ~/.ssh/<private_key> attestationAppLinux.sh user@VM-IP:~
    ssh -i ~/.ssh/<private_key> user@VM-IP
    bash attestationAppLinux.sh


