#!/usr/bin/env bash

#
# based on https://www.sandflysecurity.com/blog/using-linux-utmpdump-for-forensics-and-detecting-log-file-tampering/
# article for reviewing [b|u|w]tmp files to see if they were tampered with

coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

readonly VERSION="0.1"
readonly AUTHOR="todd fencl"

header() {
  clean
  echo -e """
----------------------------------------
Check [b|u|w]tmp for null'd entries
Run Date: ${COL_GREEN}$(date +%d-%b-%Y\ %H:%M)${COL_NC}
Version: ${COL_YELLOW}${VERSION}${COL_NC} by: ${AUTHOR}
----------------------------------------\n"""
}

main() {
  if [ ! -x /usr/bin/utmpdump ]; then
    echo -e "${CROSS} -- missing utmpdump utility"
    exit 1
  fi

  # check if utmp exists
  if [ -f "/var/run/utmp" ]; then
    echo -e "----------\nChecking ${LCYAN}UTMP${COL_NC}"
    /usr/bin/utmpdump /var/run/utmp | grep "\[0\]/*1970-01-01"
  else
    echo -e "${CROSS} -- missing /var/run/utmp file"
  fi

  # check if wtmp exists
  if [ -f "/var/log/wtmp" ]; then
    echo -e "----------\nChecking ${LCYAN}WTMP${COL_NC}"
    /usr/bin/utmpdump /var/log/wtmp | grep "\[0\]/*1970-01-01"
  else
    echo -e "${CROSS} -- missing /var/log/wtmp file"
  fi

  # check if btmp exists
  if [ -f "/var/log/btmp" ]; then
    echo -e "----------\nChecking ${LCYAN}BTMP${COL_NC}"
    /usr/bin/utmpdump /var/log/btmp | grep "\[0\]/*1970-01-01"
  else
    echo -e "${CROSS} -- missing /var/log/btmp file"
  fi
}

header
main
