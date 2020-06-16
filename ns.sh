#!/usr/bin/env bash

declare coltable="./COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

if ! [ -r "$1" ]
then
  echo -e "${CROSS} no file named passed or file not found$"
  exit -1
fi

echo -e "dig'ing testing $1 ...\n\n"

cat "$1" | while read line
do
  echo -n "$line :: "
  echo -n "$(dig +short "$line" @kopprddc01.gsiccorp.net)"
  echo
done
