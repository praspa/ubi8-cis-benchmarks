#!/bin/bash

RC=0

pass_warn_age=$(grep PASS_WARN_AGE /etc/login.defs | grep -oE '[0-9]+')

if [ $? -ne 0 ]; then
    echo "No PASS_WARN_AGE found in /etc/login.defs"
    RC=1
    exit $RC
fi

if [ ${pass_warn_age} -lt 7 ]; then
    echo "PASS_WARN_AGE configuration in /etc/login.defs is less than 7."
    RC=1
fi


exit $RC