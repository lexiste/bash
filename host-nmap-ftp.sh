#!/bin/bash

while IFS=' ' read line || [[ -n "$line" ]]; do
   split_me=( $line )
   rHost="${split_me[0]}"
   rPort="${split_me[1]}"
   echo "$rHost - $rPort FTP/SFTP check"

   #
   # check port number for FTP or SFTP and used approperiate scan module(s)
   # save the result scan to IP-PORT-DDMon.txt as some hosts have FTP and SFTP
   #
   if [ "$rPort" == "21" ]; then
      nmap -p $rPort --script=ftp* -oN $rHost-$rPort-$(date +%d%b).txt -sV --host-timeout 10m --script-timeout 5m $rHost
   else
      nmap -p $rPort --script=ssh2-enum-algos,default -oN $rHost-$rPort-$(date +%d%b).txt -sV --host-timeout 10m --script-timeout 5m  $rHost
   fi

done < "$1"
