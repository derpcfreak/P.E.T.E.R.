#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

# machine must not be running to execute this script
# check if machine is already running. If so quit
if eval machinectl --no-legend --value list | grep -q "${MACHINE}"; then
 echo -e "[${RED}FAIL${NC}] machine '${MACHINE}' is running. Script will quit here! Use 'machinectl stop ${MACHINE}' first."
 exit
fi

###################################################################
# install needed packages from official repository
###################################################################
#  jq, tar, vim, unzip, curl, wget, clevis, jose, dos2unix, dosfstools,
#  openssh-server, tftp-server, dhcp-server, samba, httpd php php-cli php-fpm

if ! systemd-nspawn  --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	dnf -y update >/dev/null
	dnf -y install jq tar vim unzip curl wget dos2unix dosfstools >/dev/null
	dnf -y install tftp-server dnsmasq samba httpd php php-cli php-fpm >/dev/null
	exit
";then
	echo -e "[${RED}FAIL${NC}] installing packages failed (machine). Will exit."
	exit
else
	echo -e "[${LIGHTGREEN} OK ${NC}] installed packages (machine)."
fi
