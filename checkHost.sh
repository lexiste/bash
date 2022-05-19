#!/usr/bin/env bash

declare coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

if [[ $# -eq 0 ]] ;
 then
   echo -e "${CROSS} No arguement, pass in host name or file"
   exit 1
fi

cat "$1" | while read host
do
  # do a ping check and note if the host is responding or not
  ping -c 2 -q ${host} > /dev/null
  if [ $? -eq 0 ]
  then
    ip=$(nslookup $host |awk -F": " '/Address/{print $2}' | tr '\n' ' ')
    echo -e "${TICK} ${host} ${ip} up"
  else
    echo -e "${CROSS} ${host} down"
  fi

  sNow="$(/bin/date +%d%b%y\ %H:%M:%S)"
  sLook="$(nslookup ${host} | grep ^Nam -A1 | awk '{print $2}')"
  sPing="$(ping -c 3 ${host} &> /dev/null && echo success || echo fail)"
  sWhoIs="$(whois ${host} |grep Organization|awk -F":" '{print $2}'| awk '{sub(/^[ \t]+/, ""); print }')"

  echo "HOSTNAME: $(/bin/hostname)" >> ~/checkHost.log
  echo "RUN TIME: ${sNow}" >> ~/checkHost.log
  echo "HOST LOOKUP: " ${host} >> ~/checkHost.log
  echo "NSLOOKUP: ${sLook}" >> ~/checkHost.log
  echo "WHOIS   : ${sWhoIs}" >> ~/checkHost.log
  echo "PING STATUS: ${sPing}" >> ~/checkHost.log
  echo "" >> ~/checkHost.log

done # cat
echo -e "${DONE} results stored in ~/checkHost.log"
