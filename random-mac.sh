#!/usr/bin/env bash

VERSION="0.2"
_RST='\e[0m'
_ALRT='\e[97\e[41m'
_GOOD='\e[92m'

set -eu # exit on error or unset variables

if [ $# == 0 ]; then
  echo -e """Reset the MAC address on the given interface
  Usage: $0 <interface> <vendor>
  use macchange --list to see all vendors supported\n
  Setting interface to ${_GOOD}ETH0${_RST} and MAC Vendor to ${_GOOD}\`Dell\`${_RST}\n"""
fi

_iface=${1:-eth0}
_vendor=${2:-Dell}

_rndVendor=$(macchanger --list | grep "${_vendor}" | shuf -n 1 | awk '{print $3}')
_rndUniq=$(echo $RANDOM | md5sum | sed 's/.\{2\}/&:/g' | cut -c 1-8)
_fullMac="$_rndVendor:$_rndUniq"

# print out some of the generated info
#echo -e "V:${_vendor}\t${_rndVendor}\t${_rndUniq}\t${_fullMac}"

#/usr/bin/macchanger --show "${_iface}" # show current MAC addr before chaning
/sbin/dhclient -r "${_iface}" # release and stop running DHCP client
/sbin/ifconfig "${_iface}" down # shutdown interface
echo ""
/usr/bin/macchanger --mac "${_fullMac}" "${_iface}" # randomize a new MAC addr on interface
/sbin/ifconfig "${_iface}" up # bring interface up
/sbin/dhclient ${_iface} # request new DHCP address
echo ""
/sbin/ip address show "${_iface}"
