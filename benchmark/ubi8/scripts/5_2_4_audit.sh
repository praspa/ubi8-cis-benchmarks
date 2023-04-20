#!/bin/bash

RC=0

for key in $(find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub'); do

    echo "Testing pub key file: ${key}"

    ownership=$(stat -c '%u:%g' "${key}")
    permissions=$(stat -c '%a' "${key}")

    echo "ownership:${ownership}"
    echo "permissions:${permissions}"

    if [ "${ownership}" != "0:0" ]; then
            echo "Pub key not root:root owned."
            RC=1
    fi

    if [ "${permissions}" != "644" ]; then
        echo "Pub key does not have 644 permissions."
        RC=1
    fi
done

exit "${RC}"
