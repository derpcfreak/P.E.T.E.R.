#!/bin/bash
# source variables
if [ ! -f "./machine.variables" ]; then
	echo "configuration file 'machine.variables' is missing. Will exit."
	exit
else
	source ./machine.variables
fi

# mkdir /var/lib/tftpboot/pxe/amd64-web
# cd /var/lib/tftpboot/pxe/
# cp amd64/initrd amd64-web/initrd
# cp amd64/linux amd64-web/linux
# ln -s -t /var/www/html/ amd64-web /var/lib/tftpboot/pxe/amd64-web

###################################################################
# configure httpd server inside machine
###################################################################
#  create folder /var/lib/tftpboot/pxe/amd64-web/
#  enable service httpd for autostart
#  link /var/www/html/amd64 to /var/lib/tftpboot/pxe/amd64-web
#  link /var/www/html/amd64-web/tuxfiles to /bindmounts/tuxfiles
#  link /bindmounts/winfiles /var/www/html/amd64-web/winfiles to /bindmounts/winfiles
systemd-nspawn --quiet --settings=false -D /var/lib/machines/${MACHINE}/ /bin/bash -c "
	mkdir -p /var/lib/tftpboot/pxe/amd64-web 2>/dev/null
	sed -i -e 's@^\(Listen\).*@\1 192.168.124.1:80@g' /etc/httpd/conf/httpd.conf
	ln -s -f /usr/lib/systemd/system/httpd.service /etc/systemd/system/multi-user.target.wants/httpd.service
	cp -f /var/lib/tftpboot/pxe/amd64/initrd /var/lib/tftpboot/pxe/amd64-web/initrd >/dev/null
	cp -f /var/lib/tftpboot/pxe/amd64/linux /var/lib/tftpboot/pxe/amd64-web/linux >/dev/null
	ln -s -f -T /var/lib/tftpboot/pxe/amd64-web /var/www/html/amd64-web
	ln -s -f -T /bindmounts/tuxfiles /var/www/html/amd64-web/tuxfiles
	ln -s -f -T /bindmounts/winfiles /var/www/html/amd64-web/winfiles
	exit
"

if [ $? -ne 0 ];then
	echo -e "[${RED}FAIL${NC}] enabling HTTP server for autostart and configuring failed (machine). Will exit."
else
	echo -e "[${LIGHTGREEN} OK ${NC}] enabled HTTP server for autostart and configured it (machine)."
fi
