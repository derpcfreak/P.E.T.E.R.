#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

###################################################################
# configure samba server inside machine
###################################################################
#  create/update /etc/samba/smb.conf
#  create samba user (win2samba/win2samba)
#  enable service smb for autostart
# Pre-allocate subuid/subgid in rootfs
#echo "root:100000:65536" >> /var/lib/machines/${MACHINE}/etc/subuid
#echo "root:100000:65536" >> /var/lib/machines/${MACHINE}/etc/subgid
systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE} /bin/bash -c "
	useradd -M -s /sbin/nologin win2samba &&
	rm -f /var/spool/mail/win2samba &&
	usermod -L win2samba &&
	echo -e 'win2samba\nwin2samba' | smbpasswd -a win2samba &&
	ln -sf /usr/lib/systemd/system/smb.service /etc/systemd/system/multi-user.target.wants/smb.service &&
	exit 0
"

# checks
systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE} /bin/bash -c "
	grep -q win2samba /etc/passwd && grep -q smb /usr/lib/systemd/system/smb.service
"

if [ $? -ne 0 ];then
	echo -e "[${RED}FAIL${NC}] enabling SAMBA server for autostart and user creation failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] enabled SAMBA server for autostart and created win2samba user (machine)."
fi

read -r -d '' smbconf <<-'EOF'
# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.
#
# Note:
# SMB1 is disabled by default. This means clients without support for SMB2 or
# SMB3 are no longer able to connect to smbd (by default).
[global]
        workgroup = SAMBA
        security = user
        passdb backend = tdbsam
        printing = cups
        printcap name = cups
        load printers = no
        cups options = raw
        min protocol = SMB2

[win2samba]
        comment = Win2Samba Share
        #path = /var/lib/tftpboot/pxe/samba/win2samba
        path = /bindmounts/win2samba/
        writeable = yes
        browseable = yes
        public = yes
        create mask = 0644
        directory mask = 0755
        write list = user
        guest ok = no
        guest only = no
        #hosts allow = 192.168.0.1/24,192.168.124.100/24
EOF

systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	echo \"${smbconf}\" >/etc/samba/smb.conf
	exit
"

if [ $? -ne 0 ];then
	echo -e "[${RED}FAIL${NC}] custom SAMBA server config failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] custom SAMBA server config applied (machine)."
fi
