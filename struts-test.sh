#!/bin/bash

while IFS=' ' read line || [[ -n "$line" ]]; do
   split_line=( $line )
   rHost="${split_line[0]}"
   rPort="${split_line[1]}"
   #echo "$rHost - $rPort - initial file check for struts"
   
   file_path="/Login.action"

   #
   # connect to the URL (IP address) and guess at the file 
   #
   if [ $rPort -eq 80 ]  || [ $rPort -eq 8080 ]; then
      conn_header="http://"
   else
      conn_header="https://"
   fi

   if [ $rPort -eq 8443 ] || [ $rPort -eq 8080 ]; then
      conn_string=$conn_header$rHost:$rPort$file_path
   else
      conn_string=$conn_header$rHost$file_path
   fi

   #echo "Host IP:PORT [$rHost:$rPort]"
   echo "connection string: $conn_string"

   curl_cmd="curl --head --location --insecure --silent $conn_string | head -1 | cut -d' ' -f2"
   echo $curl_cmd

   ## curl --head --location --insecure https://104.192.196.108/Login.action | head -1 | cut -d' ' -f2
   #curl --head --location --insecure --silent $conn_string | head -1 | cut -d' ' -f2
   for i in `seq 1 10`;
   do
      echo -n "."
      sleep 5
   done
   #
   # here we will call a struts script if we get a good response that we found
   # the file
   #

done < "$1"
