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
# create a script in /etc/profile.de to set bash prompt color
###################################################################
if ! systemd-nspawn --quiet --settings=false --bind-ro="./files/prompt-orange.sh":/tmp/prompt-orange.sh -D "/var/lib/machines/${MACHINE}/" /bin/bash -c "
        cp /tmp/prompt-orange.sh /etc/profile.d/prompt-orange.sh
        exit
";then
	echo -e "[${RED}FAIL${NC}] setting orange bash prompt failed."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] setting orange bash prompt succeeded."
fi
