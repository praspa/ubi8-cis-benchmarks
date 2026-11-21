#!/bin/bash
# CIS 4.1.1.4 Ensure audit_backlog_limit is sufficient (>= 8192).

audit_backlog_limit=$(grep -E 'kernelopts=(\S+\s+)*audit_backlog_limit=\S+\b' /boot/grub2/grubenv | grep -oE 'audit_backlog_limit=[0-9]+\b' | sed -e "s/audit_backlog_limit=//" | head -n1)

echo "audit_backlog_limit: ${audit_backlog_limit}"

if [ -z "${audit_backlog_limit}" ]; then
    echo "audit_backlog_limit is not set in /boot/grub2/grubenv."
    exit 1
fi

if [ "${audit_backlog_limit}" -lt 8192 ]; then
    echo "Audit Backlog Limit ${audit_backlog_limit} is less than 8192."
    exit 1
fi

exit 0
