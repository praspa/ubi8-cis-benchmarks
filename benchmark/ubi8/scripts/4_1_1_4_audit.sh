#!/bin/bash

RC=0

audit_backlog_limit=$(grep -E 'kernelopts=(\S+\s+)*audit_backlog_limit=\S+\b' /boot/grub2/grubenv | grep -oE 'audit_backlog_limit=[0-9]+\b' | sed -e "s/audit_backlog_limit=//")

echo "audit_backlog_limit: ${audit_backlog_limit}"

if [ ${audit_backlog_limit} -lt 8192 ]; then
    echo "Audit Backlog Limit ${audit_backlog_limit} is less than 8192."
    RC=1
fi

exit $RC

