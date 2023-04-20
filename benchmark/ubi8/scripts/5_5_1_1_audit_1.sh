#!/bin/bash

RC=0

pass_max_days=$(grep PASS_MAX_DAYS /etc/login.defs | grep -oE '[0-9]+')

if [ $? -ne 0 ]; then
    echo "No PASS_MAX_DAYS found in /etc/login.defs"
    RC=1
    exit $RC
fi

if [ ${pass_max_days} -gt 365 ]; then
    echo "PASS_MAX_DAYS configuration in /etc/login.defs is greater than 365."
    RC=1
fi


exit $RC