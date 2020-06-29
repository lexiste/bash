#!/usr/bin/env bash

##
## 1. read in htb hostname and ip as params
## 2. create ~/learning/htb/htb-<hostname>
## 3. append <ip> <hostname> to /etc/hosts file
##

set -u

declare coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

declare -A EXIT_CODES
 EXIT_CODES['unknown']=-1
 EXIT_CODES['ok']=1
 EXIT_CODES['duplicate']=1
 EXIT_CODES['missing']=5
 EXIT_CODES['failure']=10
declare _EXISTS
declare _TARGET_IP
declare _TARGET

show_usage() {
  echo -e """Setup HTB folder and update the hosts file.
  Usage: $0 -t target -a ip_address"""
  exit ${EXIT_CODES['ok']};
}

if [[ $# -eq 0 ]]; then
  show_usage;
fi

## path is optional, this is our default
while getopts "t:a:" FLAG
do
  case ${FLAG} in
    t)
      _TARGET=${OPTARG}
      ;;
    a)
      _TARGET_IP=${OPTARG}
      ;;
    *)
      show_usage
      ;;
  esac
done

## check our params exist or notify
if [[ -z ${_TARGET+x} ]]; then
  echo -e "${CROSS} target hostname not set or passed (-t)"
  show_usage
elif [[ -z ${_TARGET_IP+x} ]]; then
  echo -e "${CROSS} target ip address not set or passed (-i)"
  show_usage
fi

## check if the IP already exists; update the /etc/hosts file if not
_EXISTS="$(/usr/bin/grep ${_TARGET_IP} /etc/hosts | /usr/bin/wc -m)"
if [[ "${_EXISTS}" -gt "0" ]]; then
  echo -e "${CROSS} IP ${_TARGET_IP} already exists in /etc/hosts"
  exit ${EXIT_CODES['duplicate']};
else
  echo -e "${_TARGET_IP}\t${_TARGET}.htb" | sudo tee --append /etc/hosts
  echo -e "${TICK} ${_TARGET}.htb added to /etc/hosts file"
fi

## check if the target directory already exists; create if not
if ! [[ -d ~/learning/htb/htb-${_TARGET} ]]; then
  mkdir ~/learning/htb/htb-${_TARGET}
  if [[ $? -eq 0 ]]; then
    echo -e "${TICK} htb-${_TARGET} created successfully"
  else
    echo -e "${CROSS} error occured in mkdir call"
  fi
else
  echo -e "${CROSS} htb-${_TARGET} directory already exists"
  #exit ${EXIT_CODES['duplicate']};
fi
