#!/usr/bin/env bash

## clear the screen
clear

## display any destinations where the packets (col 1) is > 0
## this displays the packets, bytes and destination IP address
printf '#%.0s' {1..60}
## what are we showing the user ...
echo -e "\n#\n# Report the number of packets, bytes and destination(s)
# of connections blocked by iptables\n#"

sudo /usr/sbin/iptables -nvL | awk 'BEGIN {printf "\n%8s %8s %s\n", "Pkts", "Bytes", "Dest" }
 { if ($1~/^[0-9]+$/ && $1>0) printf "%8d %8d %s\n", $1,$2,$9}'

printf '#%.0s' {1..60}
printf '\n'
