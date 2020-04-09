#!/usr/bin/env bash

RST='\e[0m' #reset
ALRT='\e[97m\e[41m' #white fg / red bg
GOOD='\e[92m' #green fg / no bg (default)

if [ ! $(findmnt -M "/mnt/vm-shared") ]; then
   sudo /usr/bin/vmhgfs-fuse .host:/vm-shared /mnt/vm-shared -o subtype=vmhgfs-fuse,allow_other
   if [ $? -ne 0 ]; then
      echo -e "${ALRT}[!]${RST} An error occured in trying to mount the vmWare device!"
   else
      echo -e "${GOOD}[+]${RST} Mounted vm-shared folder to /mnt/vm-shared"
   fi
else
   echo -e "vm-shared already appears to be mounted\n"
fi

sleep 2s
