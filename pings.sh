#!/usr/bin/env bash

NC='\033[0m' #reset
ALRT='\033[1;91m' # Bold light Red FG / default bg
GOOD='\033[1;92m' # Bold light green FG / default bg
CAUTION='\033[33m' # Yellow FG
ULINE='\033[4m'

if ! [ -r "$1" ]
then
  echo -e "${CAUTION}[!] no file named passed or file not found${NC}"
  exit -1
fi

echo -e "ping testing $1 ..."

cat "$1" | while read line
do
  ping -c 1 "$line" > /dev/null
  if [ $? -ne 0 ]; then
    echo -e "${ALRT}[!!]${NC} host $line ${ULINE}down${NC}"
  else
    echo -e "${GOOD}[++]${NC} host $line ${ULINE}up${NC}"
  fi
done
