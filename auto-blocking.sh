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
##  [+] added support for Cisco Talos IOC download, nothing more than a holder
##      for more searching for bad IP's based on IOC's
##  [+] added support for bulk tor exit notes as we are seeing uptick in bad
##      actors coming from various tor nodes
##
## 2020-02-04
##  release of Kali 2020.1 and the move to not using root as the normal fullon
##  means the script needs to handle regular user execution, and elevating to
##  sudo for the iptables statements.  also, since this was a clean build, there
##  where some issues with having `set -eu` and files/folders not existing with
##  error handling and exiting which needed fixed
##
## 2020-04-09
##  changed the output to use tee (-a) command so there is feedback during
##  execution, and not just a blank screen
##
## 2020-06-01
##  added some output for errors to ${errorlog} file in the event of an
##  error since we have `set -eu`
##

VERSION="0.5.0"

set -eu # exit on error or unset variables

readonly folder=~/blackhole
readonly logfile="${folder}/blackhole.log"
readonly errorlog="${folder}/blackhole.err"
readonly spamhaus="${folder}/spamhaus-drop"
readonly bogons="${folder}/bogons-ipv4"
readonly talos="${folder}/talos-ioc"
readonly torNodes="${folder}/tor-exit-nodes"

coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

init() {
	# check if the base folder exists, create if not
  if [ ! -d "${folder}" ]; then
     echo -e "${COL_URG_RED}${CROSS} Creating folder ${folder}${COL_NC}" | tee -a ${logfile}
     mkdir -p ${folder}
  fi
	# check for log file to write to, create if not
	if [ ! -f "${logfile}" ]; then
		touch ${logfile}
    echo -e "[${COL_LIGHT_GREEN}${TICK}${COL_NC}] created ${logfile}"
	fi

  ## redirect stdout/stderr to file
	#exec &> ${logfile}
} ## init()

header() {
  clear
  echo -e """
----------------------------------------
      run date : ${COL_LIGHT_GREEN}$(date +%d-%b-%Y\ %H:%M)${COL_NC}
 source folder : ${folder}
 spamhaus file : ${spamhaus}
    bogon file : ${bogons}
    talos file : ${talos} [for record keeping]
tor exit nodes : ${torNodes} [for record keeping]
----------------------------------------\n""" | tee -a ${logfile}
} ## header()

backup-files() {
  ## backup the existing feeds files for historical purpose
  echo -e "${COL_LIGHT_GREEN}${TICK}${COL_NC} Backup of existing feeds files ..." | tee -a ${logfile}
  if [ -f "${spamhaus}" ]; then
    echo -e "  move ${COL_LIGHT_GREEN}${spamhaus}${COL_NC} to ${COL_LIGHT_GREEN}${spamhaus}.$(date +%d%b)${COL_NC}" | tee -a ${logfile}
    mv --force ${spamhaus} ${spamhaus}.$(date +%d%b)
  fi

  if [ -f "${bogons}" ]; then
    echo -e "  move ${COL_LIGHT_GREEN}${bogons}${COL_NC} to ${COL_LIGHT_GREEN}${bogons}.$(date +%d%b)${COL_NC}" | tee -a ${logfile}
    mv --force ${bogons} ${bogons}.$(date +%d%b)
  fi

  if [ -f "${talos}" ]; then
    echo -e "  move ${COL_LIGHT_GREEN}${talos}${COL_NC} to ${COL_LIGHT_GREEN}${talos}.$(date +%d%b)${COL_NC}" | tee -a ${logfile}
    mv --force ${talos} ${talos}.$(date +%d%b)
  fi

  if [ -f "${torNodes}" ]; then
    echo -e "  move ${COL_LIGHT_GREEN}${torNodes}${COL_NC} to ${COL_LIGHT_GREEN}${torNodes}.$(date +%d%b)${COL_NC}" | tee -a ${logfile}
    mv --force ${torNodes} ${torNodes}.$(date +%d%b)
  fi

  echo -e "${TICK} Completed backing up feeds files ... \n\n" | tee -a ${logfile}
} ## backup-files()

download-files(){
  echo -e "${TICK} Downloading new files ..." | tee -a ${logfile}D

  wget --timeout=20 --quiet -O ${spamhaus} https://spamhaus.org/drop/drop.lasso 2>> ${errorlog}
  # checking file size > 0, better than simple if it exists
  if [ -s ${spamhaus} ]; then
    echo -e "  downloading ${spamhaus} file" | tee -a ${logfile}
  else
    echo -e "  ${CROSS} downloading ${spamhaus} file" | tee -a ${logfile}
  fi

  wget --timeout=20 --quiet -O ${bogons} https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt 2>> ${errorlog}
  # checking file size > 0, better than simple if it exists
  if [ -s ${bogons} ]; then
    echo -e "  downloading ${bogons} file" | tee -a ${logfile}
  else
    echo -e "  ${CROSS} downloading ${bogons} file" | tee -a ${logfile}
  fi

  wget --timeout=20 --quiet -O ${talos} https://talosintelligence.com/documents/ip-blacklist 2>> ${errorlog}
  # checking file size > 0, better than simple if it exists
  if [ -s "${talos}" ]; then
    echo -e "  downloading ${talos} file" | tee -a ${logfile}
  else
    echo -e "  ${CROSS} downloading ${talos} file" | tee -a ${logfile}
  fi

  wget --quiet -O ${torNodes} https://check.torproject.org/exit-addresses 2>> ${errorlog}
  if [ -s "${torNodes}" ]; then
    echo -e "  downloading ${torNodes} file" | tee -a ${logfile}
  else
    echo -e "  ${CROSS} downloading ${torNodes} file" | tee -a ${logfile}
  fi

  echo -e "${TICK} Completed downloading feeds files ... \n\n" | tee -a ${logfile}

} ## download-files()

main() {
  ## processing and loading into iptables ...
  if [ ! -s "${spamhaus}" ]; then
     echo -e "${CROSS} unable to find drop list file ${spamhaus}" | tee -a ${logfile}
     echo -e "perhaps do: wget https://spamhaus.org/drop/drop.lasso -O ${spamhaus}" | tee -a ${logfile}
     exit 1
  else
     # convert the spamhaus file into a Cisco formated ACL file that c/would be used to update router(s)
     echo -e "Converting ${spamhaus} into ACL format files" | tee -a ${logfile}
     cat ${spamhaus} | grep -v "^;" | awk 'BEGIN {FS=" ; "}; {print $1}' | sed -f ~/scripts/subnet2mask.sed | awk '{ print "deny ip "$1" "$2" any"}' > $spamhaus.in
     cat ${spamhaus} | grep -v "^;" | awk 'BEGIN {FS=" ; "}; {print $1}' | sed -f ~/scripts/subnet2mask.sed | awk '{ print "deny ip any "$1" "$2}' > $spamhaus.out
     echo -e "Finished processing ${spamhaus}\n" | tee -a ${logfile}
  fi

  if [ ! -s "${bogons}" ]; then
     echo -e "${CROSS} unable to find the bogons file $bogons" | tee -a ${logfile}
     echo -e "perhaps a visit to https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt" | tee -a ${logfile}
     exit 1
  else
     # convert the bogons file into a Cisco formated ACL file that c/would be used to update router(s)
     echo -e "Converting ${bogons} into ACL format files" | tee -a ${logfile}
     cat ${bogons} | grep -v "^#" | sed -f ~/scripts/subnet2mask.sed | awk '{ print "deny ip "$1" "$2" any"}' > $bogons.in
     echo -e "Finished processing ${bogons}\n" | tee -a ${logfile}
  fi

  if [ ! -x /sbin/iptables ]; then
     echo -e "${CROSS} missing iptables command line tool, exiting" | tee -a ${logfile}
     exit 1
  fi

  ## finally, delete all rules, delete any chains and reset to "accept all"
  ##  this is semi-dangerous since anything other than spamhuas will be reloaded
  ##  in a prod world creating a backup, or configuration of other needed (ie. required)
  ##  rules would be in another file to be loaded as well
  ##  (EX: block telnet in/out, whitelist known hosts, etc.)
  echo -e "${CROSS} purging previous iptables rules..." | tee -a ${logfile}
  sudo /sbin/iptables -P INPUT ACCEPT
  sudo /sbin/iptables -P FORWARD ACCEPT
  sudo /sbin/iptables -P OUTPUT ACCEPT
  sudo /sbin/iptables -t nat -F
  sudo /sbin/iptables -t mangle -F
  sudo /sbin/iptables -F
  sudo /sbin/iptables -X

  ## looks like we have the input file and iptables located
  echo -e "${TICK} loading $spamhaus into iptables..." | tee -a ${logfile}
  cat "${spamhaus}" \
   | sed -e 's/;.*//' \
   | grep -v '^ *$' \
   | while read singleBlock ; do
     sudo /sbin/iptables -I INPUT -s "$singleBlock" -j DROP
     sudo /sbin/iptables -I OUTPUT -d "$singleBlock" -j DROP
     sudo /sbin/iptables -I FORWARD -s "$singleBlock" -j DROP
     sudo /sbin/iptables -I FORWARD -d "$singleBlock" -j DROP
  done
  echo -e "${DONE}"
}

init
header
backup-files
download-files
main
