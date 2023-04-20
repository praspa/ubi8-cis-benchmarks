#!/bin/bash

RC=0

RPCV="$(sudo -Hiu root env | grep '^PATH=' | cut -d= -f2)"

echo "$RPCV" | grep -q "::" && echo "root's path contains a empty directory (::)" && RC=1

echo "$RPCV" | grep -q ":$" && echo "root's path contains a trailing (:)" && RC=1

echo "root path: $RPCV"

for x in $(echo "$RPCV" | tr ":" " "); do
    if [ -d "$x" ]; then

        listing=$(ls -ldH "$x")

        echo "directory listing: $listing"

        mydir=$(echo "${listing}" | awk '{print $9}')
        owner=$(echo "${listing}" | awk '{print $3}')
        group_w=$(echo "${listing}" | awk '{print substr($1,6,1)}')
        world_w=$(echo "${listing}" | awk '{print substr($1,9,1)}')

        echo "Operating on dir: $mydir"

        if [ "${mydir}" == "." ]; then
            echo "PATH $mydir contains current working directory (.)"
            RC=1
        fi

        if [ "${owner}" != "root" ]; then
            echo "PATH $mydir is not owner by root"
            RC=1
        fi

        if [ "${group_w}" != "-" ]; then
            echo "PATH $mydir is group writable"
            RC=1
        fi

        if [ "${world_w}" != "-" ]; then
            echo "PATH $mydir is world writable"
            RC=1
        fi


    else
        echo "$x is not a directory"
    fi
done

exit $RC