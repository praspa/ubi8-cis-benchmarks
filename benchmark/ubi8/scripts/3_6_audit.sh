#!/bin/bash
# CIS 3.6 Disable IPv6: pass if IPv6 is disabled in the grub kernel options,
# or disabled for all and default interfaces in both sysctl config and runtime.

RC=1
output=""

efidir=$(find /boot/efi/EFI/* -type d -not -name 'BOOT' 2>/dev/null)
gbdir=$(find /boot -maxdepth 1 -type d -name 'grub*' 2>/dev/null)

if [ -f "$efidir"/grubenv ]; then
    grubfile="$efidir/grubenv"
else
    grubfile="$gbdir/grubenv"
fi

if [ -f "$grubfile" ] && grep "^\s*kernelopts=" "$grubfile" | grep -q 'ipv6.disable=1'; then
    output="ipv6 disabled in grub config"
    RC=0
fi

sysctl_files="/etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"

# shellcheck disable=SC2086
if grep -Eqs "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b" $sysctl_files && \
   grep -Eqs "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b" $sysctl_files && \
   sysctl net.ipv6.conf.all.disable_ipv6 2>/dev/null | grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b" && \
   sysctl net.ipv6.conf.default.disable_ipv6 2>/dev/null | grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b"; then
    if [ -n "$output" ]; then
        output="$output, and in sysctl config"
    else
        output="ipv6 disabled in sysctl config"
    fi
    RC=0
fi

if [ -n "$output" ]; then
    echo "$output"
else
    echo "IPv6 is enabled on the system"
fi

exit ${RC}
