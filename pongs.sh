#!/usr/bin/env bash

_r='\033[0m'    # reset
_a='\033[1;91m' # Bold light Red FG / default bg
_g='\033[1;92m' # Bold light green FG / default bg
_c='\033[33m'   # Yellow FG
_u='\033[4m'    # Underline text

if ! [ -r "$1" ]; then
  echo -e "${_c}[!] no file passed, or file not found${_r}"
  exit -1
fi

domains=("gspt.net" "gsiccorp.net" "innotrac.com" "prd.gsi.local" "us.gspt.net")

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
