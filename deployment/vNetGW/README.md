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

# vNet Gateway

VNet gateway (Vnet to Vnet, Site to Site VPN). Check correct network address space allocation (CIDR block) when planning subnetting and make sure they won't collide with 
other subnet range

    cd deployment/vNetGW
    terraform init
    terraform plan --out vnet-gw-plan
    terraform apply "vnet-gw-plan"