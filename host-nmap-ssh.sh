#!/bin/bash

while IFS=' ' read line || [[ -n "$line" ]]; do
   split_me=( $line )
   rHost="${split_me[0]}"
   rPort="${split_me[1]}"
   echo "[++] SSH banner check on $rHost"

   nmap -p22 -oN $rHost-ssh-$(date +%d%b).txt --host-timeout 1m --script=banner -sC -sV $rHost

done < "$1"
