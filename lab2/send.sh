#!/bin/bash

qemu-nbd -c /dev/nbd0 ~/VirtualBox\ VMs/FreeDos/DosMachine.vdi
mount  /dev/nbd0p1 /mnt/vdi/
for file in $@
do
    cp $file /mnt/vdi/
done
umount  /dev/nbd0p1
qemu-nbd -d /dev/nbd0
