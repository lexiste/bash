#!/usr/bin/env bash

declare coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

if ! [ -r "$1" ]; then
  echo -e "${CROSS} no file passed, or file not found"
  exit -1
fi

declare domains=("gspt.net" "gsiccorp.net" "innotrac.com" "prd.gsi.local" "us.gspt.net")

while read name; do
  ## when importing a file from windows, we need to trim the trailing line feed
  clean=$(tr -d '\n' <<< $name)
  clean=$(tr -d '\r' <<< $clean)
#  echo -e "[n] $clean"
  for dom in ${domains[*]}; do
    fqdn="${clean}.${dom}"
#    echo -e " [d]\t$dom"
#    echo -e " [fqdn]\t$fqdn"

    ping -c1 -q -w 2 $fqdn &>/dev/null
    if [ $? -eq 0 ]; then
      ip=$(nslookup $fqdn | awk -F": " '/Address/{print $2}' | tr '\n' ' ')
      echo $fqdn $ip
#    else
#      echo $fqdn "N/A"
    fi
  done
done < "$1"
echo -e "${DONE}"
