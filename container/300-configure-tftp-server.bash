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
# configure tftp-server inside machine to our needs
###################################################################
#  create custom tftp root directory /var/lib/tftpboot/pxe/amd64
#  create directory for systemd override file for tftp
#  create override file
#  enable tftp.service for automatic start (creating symlink)
#  enable tftp.socket  for automatic start (creating symlink)
if ! systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	mkdir -p /var/lib/tftpboot/pxe/amd64 2>/dev/null
	mkdir -p /etc/systemd/system/tftp.service.d/ 2>/dev/null
	echo -e '[Service]\nExecStart=\nExecStart=/usr/sbin/in.tftpd -s /var/lib/tftpboot/pxe/amd64 -v -v -v -v -v' > /etc/systemd/system/tftp.service.d/override.conf
	 ln -s -f /usr/lib/systemd/system/tftp.socket /etc/systemd/system/sockets.target.wants
	exit
";then
	echo -e "[${RED}FAIL${NC}] TFTP server configuration failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] TFTP server configuration success (machine)."
fi
