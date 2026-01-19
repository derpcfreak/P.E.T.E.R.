#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

# prerequisites to check before creating a
# pxe boot server inside the machine

###################################################################
# is the network card used for PXE present? (pxe0)
###################################################################
runinside='ip -oneline -tshort -echo -brief link | awk "{print $1}"'
result=$(systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE} /bin/bash -c "${runinside};exit")
if ! grep -q "^$PXEIFACE" <<< ${result};then
 echo -e "[${RED}FAIL${NC}] Interface '$PXEIFACE' was present in machine."
 echo "Interface '$PXEIFACE' not found inside machine. Please read the documentation!"
 echo "The host should map the card used for the PXE network as '$PXEIFACE' into the machine."
 exit
else
 echo -e "[ ${LIGHTGREEN}OK${NC} ] Interface '$PXEIFACE' was present in machine."
fi
unset runinside
unset result
###################################################################

###################################################################
# is the network card used for PXE present? (pxe0)
###################################################################
runinside='ip -oneline -tshort -echo -brief link | awk "{print $1}"'
result=$(systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE} /bin/bash -c "${runinside};exit")
if ! grep -q "$LANIFACE" <<< ${result};then
 echo -e "[${RED}FAIL${NC}] Interface '$LANIFACE' was present in machine."
 echo "Interface '$LANIFACE' not found inside machine. Please read the documentation!"
 echo "The host should map the card used for the uplink LAN network as '$LANIFACE' into the machine."
 exit
else
 echo -e "[ ${LIGHTGREEN}OK${NC} ] Interface '$LANIFACE' was present in machine."
fi
unset runinside
unset result
###################################################################

###################################################################
# check if machine has internet
###################################################################
checkurl='https://www.cloudflare.com'
runinside="curl -Is ${checkurl} | head -n 1 | grep '^HTTP' | awk '{print $2}'"
result=$(systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE} /bin/bash -c "${runinside};exit")
if ! $(grep -q '200' <<<"$result")
then
        echo -e "[${RED}FAIL${NC}] could not reach  ${checkurl} - no internet?"
	exit
else
        echo -e "[ ${LIGHTGREEN}OK${NC} ] ${MACHINE} could connect to ${checkurl} and reach the internet."
fi
unset runinside
unset result
###################################################################

