#!/bin/bash
# audit sgid executables

RC=0

files=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -2000 2>/dev/null)

allowed_sgid_execs="/usr/bin/write /usr/libexec/utempter/utempter"


for file in ${files}; do

  echo $allowed_sgid_execs | grep -q -w $file

  if [ $? -ne 0 ]; then
    echo "file:<$file> is not in the allowed list of sgid executables."
    RC=1
  fi

done

exit $RC