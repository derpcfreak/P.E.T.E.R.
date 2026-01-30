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
# install our custom dhcpd.conf
# - bindmount ./files/dhcpd.conf as /tmp/dhcpd.conf and copy it
#   to /etc/dhcp/dhcpd.conf
###################################################################

if ! systemd-nspawn --quiet --settings=false --bind-ro="${DHCPCFG}":/tmp/dhcpd.conf -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	cp -f /tmp/dhcpd.conf /etc/dnsmasq.d/dhcpd.conf
	exit
";then
	echo -e "[${RED}FAIL${NC}] copying/creating dhcp.cfg failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] copied/created dhcp.cfg (machine)."
fi 

###################################################################
# configure dhcpd-server for autostart inside machine
###################################################################
# - enable dhcpd daemon
if ! systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	ln -s -f /usr/lib/systemd/system/dnsmasq.service /etc/systemd/system/multi-user.target.wants/dnsmasq.service
	exit
";then
	echo -e "[${RED}FAIL${NC}] enabling DHCP server for autostart failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] enabled DHCP server for autostart (machine)."
fi
