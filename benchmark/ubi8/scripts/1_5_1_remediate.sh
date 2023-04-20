#!/bin/bash

chown root:root /boot/grub2/grub.cfg
test -f /boot/grub2/user.cfg && chown root:root /boot/grub2/user.cfg
chmod og-rwx /boot/grub2/grub.cfg
test -f /boot/grub2/user.cfg && chmod og-rwx /boot/grub2/user.cfg