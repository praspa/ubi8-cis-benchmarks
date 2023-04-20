#!/bin/bash

RC=0

UID_MIN=1000
skip_system_accounts="root sync shutdown halt"
locked="Password locked."

echo "shell check"

# check shell
while read line; do

   user=$(echo $line | awk -F: '{print $1}')
   uid=$(echo $line | awk -F: '{print $3}')
   shell=$(echo $line | awk -F: '{print $7}')

   echo "user:$user,uid:$uid,shell:$shell"

   if [ $uid -gt $UID_MIN ]; then
      echo "user:$user is greater than UID_MIN. Skipping."
      continue
   fi

   echo "$skip_system_accounts" | grep -w -q "$user"

   if [ $? -eq 0 ]; then
     echo "user:$user is an allowed interactive account. Skipping."
     continue
   fi

   if [ "$shell" != "/sbin/nologin" ]; then
     echo "user:$user has shell:<$shell> that is not set to /sbin/nologin"
     RC=1
   fi

done < /etc/passwd

# check lock

echo "lock check..."

#check if priv
passwd -S root

if [ $? -ne 0 ]; then
  echo "Unprivileged runtime. Exiting with shell check status."
  exit $RC
fi

while read line; do
   user=$(echo $line | awk -F: '{print $1}')
   uid=$(echo $line | awk -F: '{print $3}')
   shell=$(echo $line | awk -F: '{print $7}')

   echo "user:$user,uid:$uid,shell:$shell"

   if [ $uid -gt $UID_MIN ]; then
      echo "user:$user is greater than UID_MIN. Skipping."
      continue
   fi

   echo "$skip_system_accounts" | grep -w -q "$user"

   if [ $? -eq 0 ]; then
     echo "user:$user is an allowed interactive account. Skipping."
     continue
   fi

   passwd -S "$user" | grep -q "$locked"

   if [ $? -ne 0 ]; then
     echo "user:$user account is not locked."
     RC=1
   fi
done < /etc/passwd


exit $RC
