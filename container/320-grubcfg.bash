#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
        echo "configuration file 'machine.variables' is missing. Will exit."
        exit
else
        source ./machine.variables
fi

###################################################################
# install Ubuntu netoot files and create grub.cfg
# - bindmount ./files/grub.cfg as /tmp/grub.cfg and copy it
#   to /var/lib/tftpboot/pxe/amd64/grub/grub.cfg
###################################################################

systemd-nspawn --quiet --settings=false --bind-ro="${GRUBCFG}":/tmp/grub.cfg -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
        cp -f /tmp/grub.cfg /var/lib/tftpboot/pxe/amd64/grub/grub.cfg
        exit
"

if [ $? -ne 0 ];then
        echo -e "[${RED}FAIL${NC}] copying/creating grub.cfg failed (machine). Will exit."
else
        echo -e "[${LIGHTGREEN} OK ${NC}] copied/created grub.cfg (machine)."
fi

# grubsplash
systemd-nspawn --quiet --settings=false --bind-ro="${GRUBSPLASH}":/tmp/00_grubsplash.png:norbind -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
        cp /tmp/00_grubsplash.png /var/lib/tftpboot/pxe/amd64/00_grubsplash.png
        exit
"

if [ $? -ne 0 ];then
        echo -e "[${RED}FAIL${NC}] Failed to copy ${GRUBSPLASH} as grub wallpaper. Will exit."
else
        echo -e "[${LIGHTGREEN} OK ${NC}] ${GRUBSPLASH} saved as grub wallpaper."
fi
