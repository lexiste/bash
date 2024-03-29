#!/usr/bin/env bash

#
# nmap vulners module used to help identify any known vulns and corresponding cvss scores
# https://nmap.org/nsedoc/scripts/vulners.html
#
# 2020Dec27 -
#  +] added -v0 to supress output to screen since we are logging, makes running
#     easier to determine run-time issues and review output
#  -] need to work on case statement for unknown port scanning, doesn't appear to be working properly
#
#

readonly coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

file=$1

if ! [ -r "$file" ]
then
  echo -e "${CROSS} argument not passed, or file not readable\nformat of file is \`hostname port\`"
  exit 2
fi

while IFS=' ' read line || [[ -n "$line" ]]; do
   split_me=( $line )
   rHost="${split_me[0]}"
   rPort="${split_me[1]}"

   case $rPort in
      20|21|989|990)
        echo -e "${TICK} $rHost:$rPort FTP/SFTP/FTPS checks"
        nmap -v0 -p $rPort -sV -Pn --script vulners,ftp* --script-timeout 1m -oN $rHost\_$rPort-$(date +%d%b).txt  $rHost
        ;;
      22)
        echo -e "${TICK} $rHost:$rPort SSH checks"
        nmap -v0 -p $rPort -sV -Pn --script vulners,ssh2-enum-algos,default --script-timeout 1m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      53)
        echo -e "${TICK} $rHost:$rPort DNS checks and request zone transfer for gsiccorp.net domain"
        nmap -v0 -p $rPort -sV -Pn --script vulners,dns-cache-snoop,dns-zone-transfer --script-args dns-zone-transfer.domain=gsiccorp.net --host-timeout 3m --script-timeout 3m -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      69)
        echo -e "${TICK} $rHost:$rPort TFTP checks"
        echo -e "${INFO} TFPT Checks use UDP and TCP and require SUDO access"
        sudo nmap -v0 -sTU -p $rPort -sV -Pn --script vulners,tftp* --script-timeout 1m -oN $rHost\_$rPort-$(date +%d%b).txt  $rHost
        ;;
      80|443|8080|8081|8443|8444|8453)
        echo -e "${TICK} $rHost:$rPort limited HTTP(S) checks"
        # check if we have cuty capture which we use in out http-screenshot module when running with a GUI
        if [[ -x "/usr/bin/cutycapt" ]]
        then
          nmap -v0 -p $rPort -sV -Pn --script http-apache-server-status,http-config-backup,http-backup-finder,ssl-enum-ciphers,http-enum,http-headers,http-screenshot --version-intensity=5 -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        else
          nmap -v0 -p $rPort -sV -Pn --script http-apache-server-status,http-config-backup,http-backup-finder,ssl-enum-ciphers,http-enum,http-headers --version-intensity=5 -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        fi
        ## this is an error check on the previous nmap call for HTTP(s) checks...
        if [ $? -eq 139 ]
        then
            echo -e "${CROSS}${COL_ULINE}SEGMENTATION FAULT occured when scanning host $rHost on port $rPort.${COL_NC}\nReview the script(s) that are executed as part of the related scan in $0"
        fi
        ;;
      25|465|587)
        echo -e "${TICK} $rHost:$rPort SMTP checks"
        nmap -v0 -p $rPort -sV -Pn --script vulners,smtp-brute,smtp-open-relay,smtp-enum-users -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      389|636)
        echo -e "${TICK} $rHost:$rPort LDAP checks"
        echo -e "${CROSS} ${COL_ULINE}${COL_YELLOW}LDAP checking needs tuning, may not provide all information${COL_NC}"
        nmap -v0 -p $rPort -sV -Pn --script vulners,ldap* --script-timeout 3m  -Pn -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      3389|5800|5900|6129)
        echo -e "${TICK} $rHost:$rPort RDP checks"
        nmap -v0 -p $rPort -sV -Pn --script vulners,rdp-vuln-ms12-020 -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      135|137|445)
        echo -e "${TICK} $rHost:$rPort RPC checks"
        nmap -v0 -p $rPort -sV -Pn --script vulners,msrpc-enum,rpcinfo,nbstat,rpc-grind -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      2001|2002|4001|4002|6001|6002|9001|9002)
        echo -e "${TICK} $rHost:$rPort Uncommon TELNET checks"
        nmap -v0 -p $rPort -sV --script vulners,telnet-brute,banner -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      13722|13723|13724|13782|13783)
        echo -e "${TICK} $rHost:$rPort NetBackup - Network Data Management Protocol checks"
        nmap -v0 -p $rPort -sV --script ndmp-fs-info,ndmp-serverinfo,ndmp-version -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      500)
        echo -e "${TICK} $rHost:$rPort IPSEC / IKE checks"
        nmap -v0 -p $rPort -sV --script ike-version -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
      *)
        echo -e "${CROSS} undefined port to check, please update case statement with port '$rPort' and query options"
        echo -e "${COL_YELLOW}[**]${COL_NC} running version check for some generic information on port '$rPort'"
        nmap -v0 -p $rPort -sV -Pn -oN $rHost\_$rPort-$(date +%d%b).txt $rHost
        ;;
   esac

done < "$file"
