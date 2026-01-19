#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

###################################################################
# install our custom dhcpd.conf
# - bindmount ./files/dhcpd.conf as /tmp/dhcpd.conf and copy it
#   to /etc/dhcp/dhcpd.conf
###################################################################

systemd-nspawn --quiet --settings=false --bind-ro="${DHCPCFG}":/tmp/dhcpd.conf -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	cp -f /tmp/dhcpd.conf /etc/dnsmasq.d/dhcpd.conf
	exit
"

if [ $? -ne 0 ];then
	echo -e "[${RED}FAIL${NC}] copying/creating dhcp.cfg failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] copied/created dhcp.cfg (machine)."
fi 

###################################################################
# configure dhcpd-server for autostart inside machine
###################################################################
# - enable dhcpd daemon
systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	ln -s -f /usr/lib/systemd/system/dnsmasq.service /etc/systemd/system/multi-user.target.wants/dnsmasq.service
	exit
"

if [ $? -ne 0 ];then
	echo -e "[${RED}FAIL${NC}] enabling DHCP server for autostart failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] enabled DHCP server for autostart (machine)."
fi
