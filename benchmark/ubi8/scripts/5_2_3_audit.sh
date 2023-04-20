#!/bin/bash

RC=0

for key in $(find /etc/ssh -xdev -type f -name 'ssh_host_*_key'); do

    echo "Testing key file: ${key}"

    ownership=$(stat -c '%u:%g' "${key}")
    permissions=$(stat -c '%a' "${key}")

    echo "ownership:${ownership}"
    echo "permissions:${permissions}"

    if [ "${ownership}" == "0:0" ]; then
        if [ "${permissions}" != "600"]; then
            echo "root:root owned key did not have permissions 600"
            RC=1
        fi
    elif [ "${ownership}" == "0:993" ]; then
        if [ "${permissions}" != "640"]; then
            echo "root:root owned key did not have permissions 600"
            RC=1
        fi
    else
        echo "Ownership did not equal root:root or root:ssh_keys."
        RC=1
    fi
done

exit "${RC}"
