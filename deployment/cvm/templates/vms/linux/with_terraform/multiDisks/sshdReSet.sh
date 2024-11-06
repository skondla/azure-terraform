#!/bin/bash

az vm extension set --resource-group chkmarx-conf-compute-mvp --vm-name cxsast-linux-vm-1 \
    --name VMAccessForLinux --publisher Microsoft.OSTCExtensions --version 1.2 --settings settings.json
