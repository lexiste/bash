#!/usr/bin/env bash

#####
## need to just run the import process to load the iptables rules ... copy-n-paste this sniplet
#####
#cat ~/blackhole/spamhaus-drop \
# | sed -e 's/;.*//' \
# | grep -v '^ *$' \
# | while read singleBlock ; do
#   /sbin/iptables -I INPUT -s "$singleBlock" -j DROP
#   /sbin/iptables -I OUTPUT -d "$singleBlock" -j DROP
#   /sbin/iptables -I FORWARD -s "$singleBlock" -j DROP
#   /sbin/iptables -I FORWARD -d "$singleBlock" -j DROP
#done

#####
##
## script to load the spamhaus DROP file into iptables firewall rules
## should not be done less than 12hr, every 24hr is fine for this
##
## see for info: https://iplists.firehol.org/?ipset=spamhaus_drop
##
## complete replacement for cron job(s) and processing ...
## just run this script from crontab, no need to check for a file, we'll download
##  and save to ~/blackhole/
##
## added support for the Team Cymru bogons blocks as well. Bogons blocking
##  should only ever be placed at the border router to INBOUND traffic
##  (public to private networks)
##
## 2019-09-03
##  [+] added support for Cisco Talos IOC download, nothing more than a holder for more searching for bad IP's based on IOC's
##  [+] added support for bulk tor exit notes as we are seeing uptick in bad actors coming from various tor nodes
##
VERSION="0.2.1"

set -eu # exit on error or unset variables

folder=~/blackhole
logfile="$folder/blackhole.log"
spamhaus="$folder/spamhaus-drop"
bogons="$folder/bogons-ipv4"
talos="$folder/talos-ioc"
torNodes="$folder/tor-exit-nodes"

RST='\e[0m' #reset
ALRT='\e[97m\e[41m' #white fg / red bg
GOOD='\e[92m' #green fg / no bg (default)

init() {
	# check if the base folder exists, create if not
  if [ ! -d "${folder}" ]; then
     echo -e "${ALRT}[!!] Creating folder ${folder}${RST}"
     mkdir -p ${folder}
  fi
	# check for log file to write to, create if not
	if [ ! -f "${logfile}" ]; then
		touch ${logfile}
	fi
	exec &> $logfile
}

header() {

	## redirect stdout/stderr to file
  clear
  echo -e """
----------------------------------------
Run Date: ${GOOD}$(date +%d-%b-%Y\ %H:%M)${RST}
source folder: ${folder}
spamhaus file: ${spamhaus}
bogon file: ${bogons}
talos file: ${talos} [for record keeping]
tor exit nodes file: ${torNodes} [for record keeping]
----------------------------------------\n"""
}

main() {
  if [ -f "${spamhaus}" ]; then
    echo -e "move ${GOOD}${spamhaus}${RST} to ${GOOD}${spamhaus}.$(date +%d%b)${RST}"
    mv --force ${spamhaus} ${spamhaus}.$(date +%d%b)
  fi

  if [ -f "${bogons}" ]; then
    echo -e "move ${GOOD}${bogons}${RST} to ${GOOD}${bogons}.$(date +%d%b)${RST}"
    mv --force ${bogons} ${bogons}.$(date +%d%b)
  fi

  if [ -f "${talos}" ]; then
    echo -e "move ${GOOD}${talos}${RST} to ${GOOD}${talos}.$(date +%d%b)${RST}"
    mv --force ${talos} ${talos}.$(date +%d%b)
  fi

  if [ -f "${torNodes}" ]; then
    echo -e "move ${GOOD}${torNodes}${RST} to ${GOOD}${torNodes}.$(date +%d%b)${RST}"
    mv --force ${torNodes} ${torNodes}.$(date +%d%b)
  fi

  echo ""

  wget --timeout=20 --quiet -O ${spamhaus} https://spamhaus.org/drop/drop.lasso
  echo -e "${GOOD}[+]${RST} downloading ${spamhaus} file"

  wget --timeout=20 --quiet -O ${bogons} https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt
  echo -e "${GOOD}[+]${RST} downloading ${bogons} file"

  wget --timeout=20 --quiet -O ${talos} https://talosintelligence.com/documents/ip-blacklist
  if [ -s "${talos}" ]; then
    echo -e "${GOOD}[+]${RST} downloading ${talos} file"
  else
    echo -e "${ALRT}[-]${RST} downloading ${talos} file"
  fi

  wget --quiet -O ${torNodes} https://check.torproject.org/exit-addresses
  if [ -s "${torNodes}" ]; then
    echo -e "${GOOD}[+]${RST} downloading ${torNodes} file"
  else
    echo -e "${ALRT}[-]${RST} downloading ${torNodes} file"
  fi

  echo ""

  if [ ! -s "${spamhaus}" ]; then
     echo -e "${ALRT}[!!]${RST} unable to find drop list file ${spamhaus}"
     echo -e "perhaps do: wget https://spamhaus.org/drop/drop.lasso -O ${spamhaus}"
     exit 1
  else
     # convert the spamhaus file into a Cisco formated ACL file that c/would be used to update router(s)
     echo -e "converting ${spamhaus} into ACL format files"
     cat ${spamhaus} | grep -v "^;" | awk 'BEGIN {FS=" ; "}; {print $1}' | sed -f ~/scripts/subnet2mask.sed | awk '{ print "deny ip "$1" "$2" any"}' > $spamhaus.in
     cat ${spamhaus} | grep -v "^;" | awk 'BEGIN {FS=" ; "}; {print $1}' | sed -f ~/scripts/subnet2mask.sed | awk '{ print "deny ip any "$1" "$2}' > $spamhaus.out
     echo -e "finished processing ${spamhaus}\n"
  fi

  if [ ! -s "${bogons}" ]; then
     echo -e "${ALRT}[!!]${RST} unable to find the bogons file $bogons"
     echo -e "perhaps a visit to https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt"
     exit 1
  else
     # convert the bogons file into a Cisco formated ACL file that c/would be used to update router(s)
     echo -e "converting ${bogons} into ACL format files"
     cat ${bogons} | grep -v "^#" | sed -f ~/scripts/subnet2mask.sed | awk '{ print "deny ip "$1" "$2" any"}' > $bogons.in
     echo -e "finished processing ${bogons}\n"
  fi

  if [ ! -x /sbin/iptables ]; then
     echo -e "${ALRT}[!!]${RST} missing iptables command line tool, exiting"
     exit 1
  fi

  ## first, delete all rules, delete any chains and reset to "accept all"
  ##  this is semi-dangerous since anything other than spamhuas will be reloaded
  ##  in a prod world creating a backup, or configuration of other needed (ie. required)
  ##  rules would be in another file to be loaded as well
  ##  (EX: block telnet in/out, whitelist known hosts, etc.)
  echo -e "${ALRT}[!!]${RST} purging previous iptables rules..."
  sudo /sbin/iptables -P INPUT ACCEPT
  sudo  /sbin/iptables -P FORWARD ACCEPT
  sudo  /sbin/iptables -P OUTPUT ACCEPT
  sudo  /sbin/iptables -t nat -F
  sudo  /sbin/iptables -t mangle -F
  sudo  /sbin/iptables -F
  sudo  /sbin/iptables -X

  ## looks like we have the input file and iptables located
  echo -e "${GOOD}loading${RST} $spamhaus into iptables..."
  cat "${spamhaus}" \
   | sed -e 's/;.*//' \
   | grep -v '^ *$' \
   | while read singleBlock ; do
     sudo /sbin/iptables -I INPUT -s "$singleBlock" -j DROP
     sudo /sbin/iptables -I OUTPUT -d "$singleBlock" -j DROP
     sudo /sbin/iptables -I FORWARD -s "$singleBlock" -j DROP
     sudo /sbin/iptables -I FORWARD -d "$singleBlock" -j DROP
  done
}

init
header
main
