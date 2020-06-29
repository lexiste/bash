#!/usr/bin/env bash

declare coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

if ! [ -r "$1" ]
then
  echo -e "${CROSS} no file named passed or file not found"
  exit 1
fi

cat "$1" | while read host
do
  ping -c 2 -q ${host} > /dev/null
  if [ $? -eq 0 ]
  then
    ip=$(nslookup $host | awk -F": " '/Address/{print $2}' | tr '\n' ' ')
    echo -e "${TICK} ${host} ${ip} up"
  else
    echo -e "${CROSS} ${host} down"
  fi
done # cat ...
echo -e "${DONE}"
