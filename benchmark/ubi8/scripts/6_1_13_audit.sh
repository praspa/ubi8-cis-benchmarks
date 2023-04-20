#!/bin/bash
# audit suid executables

RC=0

files=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -4000 2>/dev/null)

allowed_suid_execs="/usr/bin/chage /usr/bin/mount /usr/bin/gpasswd /usr/bin/su /usr/bin/umount /usr/bin/newgrp /usr/bin/passwd /usr/libexec/dbus-1/dbus-daemon-launch-helper /usr/sbin/userhelper /usr/sbin/pam_timestamp_check /usr/sbin/unix_chkpwd"


for file in ${files}; do

  echo $allowed_suid_execs | grep -q -w $file

  if [ $? -ne 0 ]; then
    echo "file:<$file> is not in the allowed list of suid executables."
    RC=1
  fi

done

exit $RC