#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

###################################################################
# install needed packages from official repository
###################################################################
#  jq, tar, vim, unzip, curl, wget, clevis, jose, dos2unix, dosfstools,
#  openssh-server, tftp-server, dhcp-server, samba, httpd php php-cli php-fpm

systemd-nspawn  --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	dnf -y update >/dev/null
	dnf -y install jq tar vim unzip curl wget dos2unix dosfstools >/dev/null
	dnf -y install tftp-server dnsmasq samba httpd php php-cli php-fpm >/dev/null
	exit
"
if [ $? -ne 0 ];then
	echo -e "[${RED}FAIL${NC}] installing packages failed (machine). Will exit."
	exit
else
	echo -e "[${LIGHTGREEN} OK ${NC}] installed packages (machine)."
fi
