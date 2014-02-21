#!/bin/bash

oat_svc_host=openattestation.domain.tld
hostname=`hostname -f`
ipaddr=10.20.0.12
oem_manu=`dmidecode -s system-manufacturer`
oem_desc=`dmidecode -s system-product-name`
os=`cat /etc/redhat-release | awk -F"release" '{print $1}'`
os_ver=`cat /etc/redhat-release | awk -F"release" '{print $2}'`
os_desc=$os
vmm=`virsh version | grep -i hyper | awk '{print $3}'`
vmm_ver=`virsh version | grep -i hyper | awk '{print $4}'`
vmm_desc=$vmm
pcr_18=`cat \`find /sys -name pcrs\` | grep PCR-18 | cut -c 8-80 | perl -pe 's/ //g'`
bios=`dmidecode -s bios-vendor`
bios_ver=`dmidecode -s bios-version`
bios_desc=`dmidecode -s baseboard-product-name`
pcr_00=`cat \`find /sys -name pcrs\` | grep PCR-00 | cut -c 8-80 | perl -pe 's/ //g'`

echo \'$oat_svc_host\' \'$hostname\' \'$ipaddr\' \'$oem_manu\' \'$oem_desc\' \'$os\' \'$os_ver\' \'$os_desc\' \'$vmm\' \'$vmm_ver\' \'$vmm_desc\' \'$pcr_18\' \'$bios\' \'$bios_ver\' \'$bios_desc\' \'$pcr_00\'

# Enter the system hardware manufacturer (OEM) into the oat_db
oat_oem -a -h $oat_svc_host "{\"Name\":\"$oem_manu\",\"Description\":\"$oem_desc\"}"

# Enter the operating sytem into the oat_db (RH-like systems only)
oat_os -a -h $oat_svc_host "{\"Name\":\"$os\",\"Version\":\"$os_ver\",\"Description\":\"$os_desc\"}"

# Enter VMM measured launch environment (mle) into the oat_db
oat_mle -a -h $oat_svc_host "{\"Name\":\"$vmm\",\"Version\":\"$vmm_ver\",\"OsName\":\"$os\",\"OsVersion\":\"$os_ver\",\"Attestation_Type\":\"PCR\",\"MLE_Type\":\"VMM\",\"Description\":\"$vmm_desc\",\"MLE_Manifests\":[{\"Name\":\"18\",\"Value\":\"$pcr_18\"}]}"

# Enter BIOS managed launch environment (mle) into the oat_db
oat_mle -a -h $oat_svc_host "{\"Name\":\"$bios\",\"Version\":\"$bios_ver\",\"OemName\":\"$oem_manu\",\"Attestation_Type\": \"PCR\",\"MLE_Type\":\"BIOS\",\"Description\":\"$bios_desc\",\"MLE_Manifests\":[{\"Name\":\"0\",\"Value\":\"$pcr_00\"}]}"

# add the host to the database
oat_host -a -h $oat_svc_host "{\"HostName\":\"$hostname\",\"IPAddress\":\"$ipaddr\",\"Port\":\"9999\",\"BIOS_Name\":\"$bios\",\"BIOS_Version\":\"$bios_ver\",\"BIOS_Oem\":\"$oem_manu\",\"VMM_Name\":\"$vmm\",\"VMM_Version\":\"$vmm_ver\",\"VMM_OSName\":\"$os\",\"VMM_OSVersion\":\"$os_ver\",\"Email\":\"\",\"AddOn_Connection_String\":\"\",\"Description\":\"\"}"

# attest the host
oat_pollhosts -h $oat_svc_host "{\"hosts\":[\"$hostname\"]}"
