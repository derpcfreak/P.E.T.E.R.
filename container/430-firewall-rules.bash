#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi


sudo firewall-cmd --add-service=tftp --permanent
sudo firewall-cmd --add-service=dhcp --permanent
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=samba --permanent
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload
echo -e "[ ${LIGHTGREEN}OK${NC} ] Added firewall rules for tftp, dhcp, dns, http and samba. Also masquerading is turned on"
