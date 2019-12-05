#!/usr/bin/env bash

_r='\033[0m'    #reset
_a='\033[1;91m' # Bold light Red FG / default bg
_g='\033[1;92m' # Bold light green FG / default bg
_c='\033[33m'   # Yellow FG
_u='\033[4m'    # Underline text

if ! [ -r "$1" ]
then
  echo -e "${_c}[!] no file named passed or file not found${_r}"
  exit -1
fi

cat "$1" | while read host
do
  ping -c 1 -w 2 "$line" &>/dev/null
  if [ $? -eq 0 ]
  then
    ip=$(nslookup $host | awk -F": " '/Address/{print $2}' | tr '\n' ' ')
    echo -e "${_r}[+]${_r} $host $ip up"
  else
    echo -e "${_a}[!]${_r} $host ${_c}down${_r}"
  fi
done # cat ...
