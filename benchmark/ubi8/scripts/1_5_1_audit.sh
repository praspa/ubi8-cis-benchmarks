#!/bin/bash

tst1="" tst2="" tst3="" tst4="" test1="" test2="" efidir="" gbdir="" 
grubdir="" grubfile="" userfile=""
efidir=$(find /boot/efi/EFI/* -type d -not -name 'BOOT')
gbdir=$(find /boot -maxdepth 1 -type d -name 'grub*')
for file in "$efidir"/grub.cfg "$efidir"/grub.conf; do
 [ -f "$file" ] && grubdir="$efidir" && grubfile=$file
done
if [ -z "$grubdir" ]; then
 for file in "$gbdir"/grub.cfg "$gbdir"/grub.conf; do
 [ -f "$file" ] && grubdir="$gbdir" && grubfile=$file
 done
fi
userfile="$grubdir/user.cfg"
stat -c "%a" "$grubfile" | grep -Pq '^\h*[0-7]00$' && tst1=pass
output="Permissions on \"$grubfile\" are \"$(stat -c "%a" "$grubfile")\""
stat -c "%u:%g" "$grubfile" | grep -Pq '^\h*0:0$' && tst2=pass
output2="\"$grubfile\" is owned by \"$(stat -c "%U" "$grubfile")\" and 
belongs to group \"$(stat -c "%G" "$grubfile")\""
[ "$tst1" = pass ] && [ "$tst2" = pass ] && test1=pass
if [ -f "$userfile" ]; then
 stat -c "%a" "$userfile" | grep -Pq '^\h*[0-7]00$' && tst3=pass
 output3="Permissions on \"$userfile\" are \"$(stat -c "%a" "$userfile")\""
 stat -c "%u:%g" "$userfile" | grep -Pq '^\h*0:0$' && tst4=pass
 output4="\"$userfile\" is owned by \"$(stat -c "%U" "$userfile")\" and 
belongs to group \"$(stat -c "%G" "$userfile")\""
 [ "$tst3" = pass ] && [ "$tst4" = pass ] && test2=pass
else
 test2=pass
fi
[ "$test1" = pass ] && [ "$test2" = pass ] && passing=true
# If passing is true we pass
if [ "$passing" = true ] ; then
 echo "PASSED:"
 echo "$output"
 echo "$output2"
 [ -n "$output3" ] && echo "$output3"
 [ -n "$output4" ] && echo "$output4"
else
 # print the reason why we are failing
 echo "FAILED:"
 echo "$output"
 echo "$output2"
 [ -n "$output3" ] && echo "$output3"
 [ -n "$output4" ] && echo "$output4"
fi