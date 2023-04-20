#!/bin/bash

# 1.1.21 sticky bit on world write directories
chmod 1777 /tmp/ /var/tmp

# Permissions on Warning banner files - 1.8.1.4, 1.8.1.5, 1.8.1.6
chown root:root /etc/issue
chmod 644 /etc/issue
chown root:root /etc/motd
chmod 644 /etc/motd
chown root:root /etc/issue.net
chmod 644 /etc/issue.net

# 4.2.3 - Ensure permissions on all logfiles are configured
chmod 640 /var/log/dnf.librepo.log /var/log/dnf.log /var/log/dnf.rpm.log /var/log/hawkey.log /var/log/rhsm/rhsm.log

# 5.5.1.4
sed -i "s/INACTIVE=-1/INACTIVE=30/" /etc/default/useradd

# 5.5.2 - lock service accounts
#passwd -l bin
#passwd -l daemon
#passwd -l adm
#passwd -l lp
#passwd -l mail
#passwd -l operator
#passwd -l games
#passwd -l ftp
sed -i "s/^bin:*:/bin:!!:/" /etc/shadow
sed -i "s/^daemon:*:/daemon:!!:/" /etc/shadow
sed -i "s/^adm:*:/adm:!!:/" /etc/shadow
sed -i "s/^lp:*:/lp:!!:/" /etc/shadow
sed -i "s/^mail:*:/mail:!!:/" /etc/shadow
sed -i "s/^operator:*:/operator:!!:/" /etc/shadow
sed -i "s/^games:*:/games:!!:/" /etc/shadow
sed -i "s/^ftp:*:/ftp:!!:/" /etc/shadow

# 6.1.10 - remove world write
if [ -f /run/.containerenv ]; then
  chmod 664 /run/.containerenv
fi

if [ -f /etc/resolv.conf ]; then
   chmod 664 /etc/resolv.conf
fi

if [ -f /dev/termination-log ]; then
   chmod 664 /dev/termination-log
fi

   
