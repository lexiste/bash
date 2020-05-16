#!/usr/bin/env bash

#
# nmap vulners module used to help identify any known vulns and corresponding cvss scores
# https://nmap.org/nsedoc/scripts/vulners.html
#

NC='\033[0m' #reset
ALRT='\033[1;91m' # Bold light Red FG / default bg
GOOD='\033[1;92m' # Bold light green FG / default bg
CAUTION='\033[33m' # Yellow FG
ULINE='\033[4m'

file=$1

if ! [ -r "$file" ]
then
  echo -e "${ALRT}argument not passed, or file not readable${NC}\nformat of file is \`hostname port\`"
  exit 2
fi

while IFS=' ' read line || [[ -n "$line" ]]; do
   split_me=( $line )
   rHost="${split_me[0]}"
   rPort="${split_me[1]}"
#   echo "checking: $rHost:$rPort"

   case $rPort in
      20|21|69|989|990)
        echo -e "${GOOD}[+]${NC} $rHost FTP/SFTP/FTPS checks"
        nmap -p $rPort -sV -Pn --script vulners,ftp* --host-timeout 10m --script-timeout 5m -oN $rHost\_$rPort-$(date +%d%b).txt  $rHost
        ;;
      22)
        echo -e "${GOOD}[+]${NC} $rHost SSH checks"
        nmap -p $rPort -sV -Pn --script vulners,ssh2-enum-algos,default --host-timeout 10m --script-timeout 5m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      53)
        echo -e "${GOOD}[+]${NC} $rHost DNS checks and request zone transfer for gsiccorp.net domain"
        nmap -p $rPort -sV -Pn --script vulners,dns-cache-snoop,dns-zone-transfer --script-args dns-zone-transfer.domain=gsiccorp.net --host-timeout 3m --script-timeout 3m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      80|443|8080|8081|8443)
        echo -e "${GOOD}[+]${NC} $rHost limited HTTP(S) checks"
        # check if we have cuty capture which we use in out http-screenshot module when running with a GUI
        if [[ -x "/usr/bin/cutycapt" ]]
        then
          nmap -p $rPort -sV -Pn --script http-apache-server-status,http-config-backup,http-backup-finder,ssl-enum-ciphers,http-enum,http-headers,http-screenshot --version-intensity=5 --script-timeout 3m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        else
          nmap -p $rPort -sV -Pn --script http-apache-server-status,http-config-backup,http-backup-finder,ssl-enum-ciphers,http-enum,http-headers --version-intensity=5 --script-timeout 3m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        fi
        if [ $? -eq 139 ]
        then
            echo -e "${ALRT}${ULINE}SEGMENTATION FAULT occured when scanning host $rHost on port $rPort.${NC}\nReview the script(s) that are executed as part of the related scan in $0"
        fi
        ;;
      389|636)
        echo -e "${GOOD}[+]${NC} $rHost LDAP checks"
        echo -e "${ALRT}[!!]${NC} ${ULINE}${CAUTION}LDAP checking needs tuning, may not provide all information${NC}"
        nmap -p $rPort -sV -Pn --script vulners,ldap* --script-timeout 3m  -Pn -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      3389)
        echo -e "${GOOD}[+]${NC} $rHost RDP checks"
        nmap -p $rPort -sV -Pn --script vulners,rdp-vuln-ms12-020,rdp-enum-encryption --script-timeout 5m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      135|137|445)
        echo -e "${GOOD}[+]${NC} $rHost RPC checks"
        nmap -p $rPort -sV -Pn --script vulners,msrpc-enum,rpcinfo,nbstat,rpc-grind --script-timeout 5m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      *)
        echo -e "${ALRT}[!!]${NC} undefined port to check, please update case statement with port '$rPort' and query options"
        echo -e "${CAUTION}[**]${NC} running version check for some generic information on irregular port '$rPort'"
        nmap -p $rPort -sV -Pn $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
   esac

done < "$file"
