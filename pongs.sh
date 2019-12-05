#!/usr/bin/env bash

_r='\033[0m'    #reset
_a='\033[1;91m' # Bold light Red FG / default bg
_g='\033[1;92m' # Bold light green FG / default bg
_c='\033[33m'   # Yellow FG
_u='\033[4m'    # Underline text

if ! [ -r "$1" ]; then
  echo -e "${_c}[!] no file passed, or file not found${_r}"
  exit -1
fi

domains=(".gspt.net" ".gsiccorp.net")
while read name; do
  for i in ${!domains[*]}
  do
    host="$name${domains[$i]}"
#    fping --alive --addr --name $host
    ping -c1 -q -w 2 $host &>/dev/null
    if [ $? -eq 0 ]; then
      ip=$(nslookup $host | awk -F": " '/Address/{print $2}' | tr '\n' ' ')
      echo $host $ip
    else
      echo $host not found
    fi
  done
done < "$1"
