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
# install Ubuntu netoot files and create grub.cfg
# - bindmount ./files/grub.cfg as /tmp/grub.cfg and copy it
#   to /var/lib/tftpboot/pxe/amd64/grub/grub.cfg
###################################################################

if ! systemd-nspawn --quiet --settings=false --bind-ro="${GRUBCFG}":/tmp/grub.cfg -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
        cp -f /tmp/grub.cfg /var/lib/tftpboot/pxe/amd64/grub/grub.cfg
        exit
";then
        echo -e "[${RED}FAIL${NC}] copying/creating grub.cfg failed (machine). Will exit."
else
        echo -e "[${LIGHTGREEN} OK ${NC}] copied/created grub.cfg (machine)."
fi

# grubsplash
if ! systemd-nspawn --quiet --settings=false --bind-ro="${GRUBSPLASH}":/tmp/00_grubsplash.png:norbind -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
        cp /tmp/00_grubsplash.png /var/lib/tftpboot/pxe/amd64/00_grubsplash.png
        exit
";then
        echo -e "[${RED}FAIL${NC}] Failed to copy ${GRUBSPLASH} as grub wallpaper. Will exit."
else
        echo -e "[${LIGHTGREEN} OK ${NC}] ${GRUBSPLASH} saved as grub wallpaper."
fi
