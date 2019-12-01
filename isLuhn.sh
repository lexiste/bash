#!/usr/bin/env bash

#pan=$1
read pan
panlen=${#pan}

for i in $(seq $((panlen - 1)) -1 0); do
  digit=${pan:$i:1}
  #if [ $(((panlen-i) % 2)) -eq 0 ]; then
  if (((panlen - i) % 2 == 0)); then
     #even
     ((digit*=2))
     [ ${#digit} -eq 2 ] && digit=$((${digit:0:1}+${digit:1:1}))
  fi
  ((sum+=digit))
done

#[ $((sum % 10)) -eq 0 ] || exit 1
((sum % 10 == 0)) || exit 1
