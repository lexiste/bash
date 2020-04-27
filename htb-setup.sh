#!/usr/bin/env bash

##
## 1. read in htb hostname and ip as params
## 2. create ~/learning/htb/htb-<hostname>
## 3. append <ip> <hostname> to /etc/hosts file
##

RESET='\e[0m' #reset
ALERT='\e[97m\e[41m' #white fg / red bg
GOOD='\e[92m' #green fg / no bg (default)
WARN='\e[33m'

declare -A EXIT_CODES
EXIT_CODES['unknown']=-1
EXIT_CODES['ok']=1
EXIT_CODES['duplicate']=1
EXIT_CODES['missing']=5
EXIT_CODES['failure']=10

show_usage() {
  echo -e """Setup HTB folder and update the hosts file.
  Usage: $0 -t target -a ip_address """
  exit ${EXIT_CODES['ok']};
}

if [[ $# -eq 0 ]]; then
  show_usage;
fi

while getopts "t:a:" FLAG
do
  case $FLAG in
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
  echo -e "${WARN}[!]${RESET} target hostname not set or passed (-t)"
  show_usage
elif [[ -z ${_TARGET_IP+x} ]]; then
  echo -e "${WARN}[!]${RESET} target ip address not set or passed (-i)"
  show_usage
fi

## check if the IP already exists; update the /etc/hosts file if not
_EXISTS="$(/usr/bin/grep ${_TARGET_IP} /etc/hosts | /usr/bin/wc -m)"
if [[ "${_EXISTS}" -gt "0" ]]; then
  echo -e "${ALERT}[!]${RESET} IP ${_TARGET_IP} already exists in /etc/hosts"
  exit ${EXIT_CODES['duplicate']};
else
  echo -e "${_TARGET_IP}\t${_TARGET}.htb" | sudo tee --append /etc/hosts
  echo -e "${GOOD}[+]${RESET} ${_TARGET}.htb added to /etc/hosts file"
fi

## check if the target directory already exists; create if not
if ! [[ -d ~/learning/htb/htb-${_TARGET} ]]; then
  mkdir ~/learning/htb/htb-${_TARGET}
  if [[ $? -eq 0 ]]; then
    echo -e "${GOOD}[+]${RESET} htb-${_TARGET} created successfully"
  else
    echo -e "${ALERT}[!]${RESET} error occured in mkdir call"
  fi
else
  echo -e "${ALERT}[!]${RESET} htb-${_TARGET} directory already exists"
  exit ${EXIT_CODES['duplicate']};
fi
