#!/bin/bash
# CIS 5.2.3 Ensure permissions on SSH private host key files are configured.
# root:root keys must be 600 or stricter; root:ssh_keys keys must be 640 or stricter.

RC=0

while read -r key; do
    [ -z "${key}" ] && continue

    echo "Testing key file: ${key}"

    ownership=$(stat -c '%U:%G' "${key}")
    permissions=$(stat -c '%a' "${key}")

    echo "ownership:${ownership}"
    echo "permissions:${permissions}"

    case "${ownership}" in
        root:root)   max=600 ;;
        root:ssh_keys) max=640 ;;
        *)
            echo "Ownership ${ownership} is not root:root or root:ssh_keys."
            RC=1
            continue
            ;;
    esac

    if (( (8#${permissions} & ~8#${max}) != 0 )); then
        echo "${ownership} owned key has permissions ${permissions}; expected ${max} or more restrictive."
        RC=1
    fi
done < <(find /etc/ssh -xdev -type f -name 'ssh_host_*_key')

exit "${RC}"
