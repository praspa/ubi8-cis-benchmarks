#!/bin/bash

RC=1

rpm -q firewalld

FIREWALLD_RC=$?

rpm -q nftables

NFTABLES_RC=$?

rpm -q iptables iptables-services

IPTABLES_RC=$?

if [[ "${FIREWALLD_RC}" -eq 0 || "${NFTABLES_RC}" -eq 0 || "${IPTABLES_RC}" -eq 0 ]]  ; then
    echo "A firewall package is installed."
    RC=0
else
    echo "No firewall package installed."
    RC=1
fi

exit $RC
