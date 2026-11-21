#!/bin/bash
# CIS 1.5.2 Ensure bootloader password is set
tst1="" tst2="" output="" grubdir="" grubfile=""
efidir=$(find /boot/efi/EFI/* -type d -not -name 'BOOT' 2>/dev/null)
gbdir=$(find /boot -maxdepth 1 -type d -name 'grub*' 2>/dev/null)
if [ -f "$efidir"/grub.cfg ]; then
 grubdir="$efidir" && grubfile="$efidir/grub.cfg"
elif [ -f "$gbdir"/grub.cfg ]; then
 grubdir="$gbdir" && grubfile="$gbdir/grub.cfg"
fi
userfile="$grubdir/user.cfg"
[ -f "$userfile" ] && grep -Pq '^\h*GRUB2_PASSWORD\h*=\h*.+$' "$userfile" && \
 output="PASSED: bootloader password set in \"$userfile\""
if [ -z "$output" ] && [ -f "$grubfile" ]; then
 grep -Piq '^\h*set\h+superusers\h*=\h*"?[^"\n\r]+"?(\h+.*)?$' "$grubfile" && tst1=pass
 grep -Piq '^\h*password\h+\H+\h+.+$' "$grubfile" && tst2=pass
 [ "$tst1" = pass ] && [ "$tst2" = pass ] && output="PASSED: bootloader password set in \"$grubfile\""
fi
if [ -n "$output" ]; then
 echo "$output"
 exit 0
fi
echo "FAILED: bootloader password is not set"
exit 1
