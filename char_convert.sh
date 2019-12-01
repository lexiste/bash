#!/usr/bin/env bash

#
# convert this string
# 45,120,49,45,81,45,45,120,50,45,81,45,45,120,51,45,81,45,45,120,52,45,81,45,45,120,53,45,81,45,45,120,54,45,81,45,45,120,55,45,81,45,45,120,56,45,81,45,45,120,57,45,81,45,45,120,49,48,45,81,45,45,120,49,49,45,81,45,45,120,49,50,45,81,45,45,120,49,51,45,81,45,45,120,49,52,45,81,45,45,120,49,53,45,81,45,45,120,49,54,45,81,45,45,120,49,55,45,81,45,45,120,49,56,45,81,45,45,120,49,57,45,81,45,45,120,50,48,45,81,45,45,120,50,49,45,81,45,45,120,50,50,45,81,45,45,120,50,51,45,81,45,45,120,50,52,45,81,45,45,120,50,53,45,81,45,45,120,50,54,45,81,45,45,120,50,55,45,81,45,45,120,50,56,45,81,45,45,120,50,57,45,81,45,45,120,51,48,45,81,45,45,120,51,49,45,81,45,45,120,51,50,45,81,45,45,120,51,51,45,81,45,45,120,51,52,45,81,45,45,120,51,53,45,81,45,45,120,51,54,45,81,45,45,120,51,55,45,81,45,45,120,51,56,45,81,45,45,120,51,57,45,81,45,45,120,52,48,45,81,45,45,120,52,49,45,81,45,45,120,52,50,45,81,45,45,120,52,51,45,81,45,45,120,52,52,45,81,45,45,120,52,53,45,81,45,45,120,52,54,45,81,45
#
#

chars=("45" "120" "49" "45" "81" "45" "45" "120" "50" "45" "81" "45" "45" "120" "51" "45" "81" "45" "45" "120" "52" "45" "81" "45" "45" "120" "53" "45" "81" "45" "45" "120" "54" "45" "81" "45" "45" "120" "55" "45" "81" "45" "45" "120" "56" "45" "81" "45" "45" "120" "57" "45" "81" "45" "45" "120" "49" "48" "45" "81" "45" "45" "120" "49" "49" "45" "81" "45" "45" "120" "49" "50" "45" "81" "45" "45" "120" "49" "51" "45" "81" "45" "45" "120" "49" "52" "45" "81" "45" "45" "120" "49" "53" "45" "81" "45" "45" "120" "49" "54" "45" "81" "45" "45" "120" "49" "55" "45" "81" "45" "45" "120" "49" "56" "45" "81" "45" "45" "120" "49" "57" "45" "81" "45" "45" "120" "50" "48" "45" "81" "45" "45" "120" "50" "49" "45" "81" "45" "45" "120" "50" "50" "45" "81" "45" "45" "120" "50" "51" "45" "81" "45" "45" "120" "50" "52" "45" "81" "45" "45" "120" "50" "53" "45" "81" "45" "45" "120" "50" "54" "45" "81" "45" "45" "120" "50" "55" "45" "81" "45" "45" "120" "50" "56" "45" "81" "45" "45" "120" "50" "57" "45" "81" "45" "45" "120" "51" "48" "45" "81" "45" "45" "120" "51" "49" "45" "81" "45" "45" "120" "51" "50" "45" "81" "45" "45" "120" "51" "51" "45" "81" "45" "45" "120" "51" "52" "45" "81" "45" "45" "120" "51" "53" "45" "81" "45" "45" "120" "51" "54" "45" "81" "45" "45" "120" "51" "55" "45" "81" "45" "45" "120" "51" "56" "45" "81" "45" "45" "120" "51" "57" "45" "81" "45" "45" "120" "52" "48" "45" "81" "45" "45" "120" "52" "49" "45" "81" "45" "45" "120" "52" "50" "45" "81" "45" "45" "120" "52" "51" "45" "81" "45" "45" "120" "52" "52" "45" "81" "45" "45" "120" "52" "53" "45" "81" "45" "45" "120" "52" "54" "45" "81" "45")

short=("45" "120" "49")

for c in ${chars[@]}; do
  printf "\x$(printf %x $c)"
done
echo
