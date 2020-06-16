#!/usr/bin/env bash

coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f $coltable ]]; then
   source ${coltable}
fi

if [[ ! $(findmnt -M "/mnt/vm-shared") ]]; then
   sudo /usr/bin/vmhgfs-fuse .host:/vm-shared /mnt/vm-shared -o subtype=vmhgfs-fuse,allow_other
   if [ $? -ne 0 ]; then
      echo -e "${CROSS} An error occured in trying to mount the vmWare device!"
   else
      echo -e "${TICK} Mounted vm-shared folder to /mnt/vm-shared"
   fi
else
   echo -e "vm-shared already appears to be mounted\n"
fi

sleep 2s
echo -e "${DONE}"
