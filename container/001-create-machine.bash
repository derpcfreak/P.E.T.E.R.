#!/bin/bash

# variables
# check SELinux status. We can only work, if we are NOT Enforcing
if [ "$(getenforce)" == "Enforcing" ]; then
	echo "You must temporarely set SELinux to 'Permissive' to continue!"
	echo ""
	echo "The better approach would be to run"
	echo "./000-run-all-bash-scripts.run"
	exit
fi

# source variables from ./machine.variables
if [ ! -f "./machine.variables" ]; then
	echo -e "[\033[0;31mFAIL\033[0m] configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
	echo -e "[\033[1;32m OK \033[0m] configuration file 'machine.variables' is present."
fi
#######################################################################
# All UPPERCASE variables have been sourced from ${machine.variables} #
#######################################################################

# set timezone for localhost (this will be reflected into the container)
timedatectl set-timezone "${TIMEZONE}"
timedatectl set-local-rtc 0
echo -e "[${LIGHTGREEN} OK ${NC}] timezone on this host has been set to ${TIMEZONE}"

# check if machine is already running. If so quit
if $(machinectl --no-legend --value list | grep -q ${MACHINE}); then
 echo -e "[${RED}FAIL${NC}] machine '${MACHINE}' is running. Script will quit here! Use 'machinectl stop ${MACHINE}' first."
 exit
fi


# create almalinux systemd-container
# if ! exists and has a size greater than zero
if [ ! -s "$OUTFILE" ]; then
 # remove folder if ctrlc is pressed
 trap "rm -r -f /var/lib/machines/${MACHINE};exit" SIGINT
 echo -n "creating a fresh almalinux systemd-machine in /var/lib/machines/${MACHINE} ..."
 dnf install -y -c /etc/yum.repos.d/almalinux-baseos.repo --releasever=10.1 --repo=baseos --best --installroot=/var/lib/machines/${MACHINE} --setopt=install_weak_deps=False almalinux-release dnf glibc-langpack-en yum dnf rootfiles systemd shadow-utils util-linux passwd vim-minimal iproute iputils less hostname >/dev/null 2>&1
 trap - SIGINT # remove trap
 echo "done"
 # create backup of the container
 trap "rm -f "${OUTFILE}";exit" SIGINT
 importctl --class=machine export-tar ${MACHINE} "${OUTFILE}"
 while [[ $(importctl list-transfers | grep -q '^No.transfers') ]]; do echo "ongoing transfer...";done
 trap - SIGINT # remove trap
fi

# show success if image is now present
if [ -s "$OUTFILE" ]; then
 echo -e "[ ${LIGHTGREEN}OK${NC} ] rootfs $OUTFILE present."
 # outfile present but machine not yet created
 if [ ! -d /var/lib/machines/${MACHINE} ]
 then
	importctl --class=machine import-tar "${OUTFILE}" ${MACHINE}
   	# Do something knowing the pid exists, i.e. the process with $PID is running
        while [[ $(importctl list-transfers | grep -q '^No.transfers') ]]
	do
	 echo "import still ongoing..."
	done
 fi
else
 echo -e "[${RED}FAIL${NC}] rootfs $OUTFILE missing. Will exit."
 exit
fi

# set root password to root/root inside
systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE} /bin/bash -c '
	echo -e "root\nroot"|passwd 2>/dev/null
	exit
' >/dev/null && echo -e "[${LIGHTGREEN} OK ${NC}] root password has been set inside machine. (root/root)"

# install openssh inside machine, set ssh port to 2222
# allow ssh root login, set sshd listenaddress to 127.0.0.1/::1 (localhost only)
#systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "dnf -y install openssh-server;sed -i -e 's@^[#]*\(Port\).*@\1 ${SSHPORT}@g' /etc/ssh/sshd_config;sed -i -e 's@^[#]*\(PermitRootLogin\).*@\1 yes@g' /etc/ssh/sshd_config;sed -i -e 's@^[#]*\(ListenAddress\).*0.0.0.0@\1 127.0.0.1@g' /etc/ssh/sshd_config;sed -i -e 's@^[#]*\(ListenAddress\).*\:\:.*@\1 \:\:1@g' /etc/ssh/sshd_config;exit" >/dev/null && echo -e "[${LIGHTGREEN} OK ${NC}] SSH Server on port ${SSHPORT} (localhost) installed inside machine."

# set hostname inside machine
systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	echo ${MACHINE} > /etc/hostname
	exit
" && echo -e "[${LIGHTGREEN} OK ${NC}] machine hostname set to ${MACHINE}"

# remove old sshd machine keys
systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	rm -f /etc/ssh/ssh_host_*
	exit
" && echo -e "[${LIGHTGREEN} OK ${NC}] previous SSH host keys ssh_host* deleted. (machine)"

# create /etc/systemd/nspawn if not yet exists
mkdir -p /etc/systemd/nspawn 2>/dev/null

# create local folders for bindmounts
# based on variables from config file
mkdir -p "${BM_WIN2SAMBA}" 2>/dev/null
mkdir -p "${BM_TUXFILES}" 2>/dev/null
mkdir -p "${BM_WINFILES}" 2>/dev/null

# create the symbolic link (must be relative) for win2samba.iso
mkdir "${BM_WINFILES}/0000-cloud-init/" 2>/dev/null
ln -s '../../win2samba/boot/win2samba.iso' "${BM_WINFILES}/0000-cloud-init/win2samba.iso" 2>/dev/null

# set correct permissions for local folders
# We assume, that user 'liadm' has uid=1000
# which matches user 'win2samba' inside the container
# so both the local machine and the container have
# access to the files.
chown -R root:${ADMINUSER} "${BM_WIN2SAMBA}"
chmod 0775 -R "${BM_WIN2SAMBA}"

# Create nspawn file for machine
# The file below will bring all interfaces from the 'real' host
# into the machine.
cat <<-EOF > /etc/systemd/nspawn/${MACHINE}.nspawn && echo -e "[${LIGHTGREEN} OK ${NC}] created /etc/systemd/nspawn/${MACHINE}.nspawn (this host)" 
[Exec]
Boot=true
PrivateUsers=no
Hostname=${MACHINE}
Capability=CAP_NET_ADMIN CAP_NET_RAW

[Network]
Private=no
VirtualEthernet=no
Port=udp:69:udp:69
Port=tcp:80:tcp:80
Port=tcp:445:tcp:445
Port=tcp:139:tcp:139
Port=udp:67:udp:67
Port=udp:68:udp:68

[Files]
# Adds bind mounts from the host into the systemd-container.
# Takes a single path, a pair of two paths separated by a colon,
# or a triplet of two paths plus an option string separated by colons.
# /singlepath
# /pathhere:/paththere
# /pathhere:/paththere:options
Bind=${BM_WIN2SAMBA}:/bindmounts/win2samba
BindReadOnly=${BM_TUXFILES}:/bindmounts/tuxfiles
BindReadOnly=${BM_WINFILES}:/bindmounts/winfiles
EOF

# create the sambacheck.bash script as /root/sambacheck.bash
systemd-nspawn --quiet --settings=false --bind-ro="${SAMBACHECK}":/tmp/sambacheck.bash -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	cp -f /tmp/sambacheck.bash /root/sambacheck.bash
	chmod +x /root/sambacheck.bash
	exit
"

# copy crontab (including task every minute for sambacheck.bash) to /etc/crontab
systemd-nspawn --quiet --settings=false --bind-ro="${CRONTAB}":/tmp/crontab -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	cp -f /tmp/crontab /etc/crontab
	chmod 0644 /etc/crontab
	chown root:root /etc/crontab
	exit
"

################################################################################
# Since the /etc/systemd/nspawn/machinename.nspawn file now exists the machine #
# will use it when starting. The settings in the .nspawn file are leading.     #
################################################################################
echo '#####################################################################################'
echo "You can start your machine with   : machinectl start ${MACHINE}."
echo "You can login to your machine with: machinectl shell ${MACHINE}"
echo "The root password has been set to : root"
echo '#####################################################################################'
