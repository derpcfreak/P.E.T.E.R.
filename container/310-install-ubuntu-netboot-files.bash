#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

###################################################################
# install Ubuntu netboot files
#  - bindmount ./files/ubuntu-24.04.2-netboot-amd64.tar.gz as /tmp/netboot.tar.gz
#    and extract it to /var/lib/tftpboot/pxe
#   (https://releases.ubuntu.com/noble/ubuntu-24.04.2-netboot-amd64.tar.gz)
#  - tar command must be already available!
#  - /var/lib/tftpboot/pxe must already by present!
###################################################################

systemd-nspawn --quiet --settings=false --bind-ro="${NBSOURCEFILES}":/tmp/netboot.tar.gz:norbind -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	tar xzf /tmp/netboot.tar.gz -C /var/lib/tftpboot/pxe/ >/dev/null
	# fix for the 'revocations.efi' error message
	# This is only a cosmetic fix to not show an error message.
	# revocations.efi is not needed at all. If you want to reduce boot time
	# comment the next line and live with the error message. Or accept the
	# that bootx64.efi (copied to revocations.efi - 945K) is loaded a second time.
	if [ ! -f /var/lib/tftpboot/pxe/amd64/revocations.efi ]; then cp /var/lib/tftpboot/pxe/amd64/bootx64.efi /var/lib/tftpboot/pxe/amd64/revocations.efi;fi
	exit
"

if [ $? -ne 0 ];then
	echo -e "[${RED}FAIL${NC}] Ubuntu netboot files installation failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] Ubuntu netboot files prepared (machine)."
fi 
