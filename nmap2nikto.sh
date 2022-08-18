#!/usr/bin/env bash

#####
##
## 2020-12-06
#####

VERSION="1.0.2"

set -eu # exit on errors or unset variables
readonly coltable="/home/todd/scripts/bash/COL_TABLE"
readonly ports="80 443 8080 8443"
readonly massFilteredList="targets.lst"
readonly massUniqueList="unique-hosts.lst"
readonly cur_date=$(date +%Y-%b-%d)

if [[ -f ${coltable} ]]; then
	source ${coltable}
fi

echo -e "Running ${COL_GREEN}$BASH_SOURCE${COL_NC} on ${COL_ULINE}$(/bin/hostname)${COL_NC} on ${COL_ULINE}$(date)${COL_NC}"

## for a massive, external audit of Radial with multiple /24 and /23 blocks, masscan should be used to generate the
##  targets file ... and we have a built configuration file (radial-mass.confi) that includes our net blocks and
##  other configuration data.
##
## something as simple as the following could be used: (just check the radial-mass.conf file for the correct ports defined)

##
## masscan output shows 0/icmp for hosts that reply, filter this out since it is not a port listed this is what the if()
##  statement allows, it will print if col 4 is not 0/icmp
echo -e ${INFO} "executing initial host detection using masscan"
if [ ! -f "/home/todd/pentest/radial-mass.conf" ]; then
	echo -e "${CROSS} Missing massscan conf file \"radial-mass.conf\""
	exit 999
fi
sudo /usr/bin/masscan -c /home/todd/pentest/radial-mass.conf | awk '{ if ($4 != "0/icmp") print $6}' > ${massFilteredList}


## perform some de-dup on the targets file by running through unique but since we can't overwrite the file, write to temp
##  then move it back
## this is due to masscan reporting on each open port, if we find one (1) open port we want to scan using nmap and nikto
unique -inp=${massFilteredList} t.$$; mv t.$$ ${massUniqueList}


## take the file targets.lst as input for the initial nmap scan
##  by default, nmap scans the top 1,000 ports including the most common alternate web ports (8080, 8443, etc)
echo -e "${INFO} executing ${COL_GREEN}nmap${COL_NC} scans output to ${COL_GREEN}${curdate}\_nmap_scan${COL_NC}"
nmap -T3 -n -Pn -iL targets.lst -oA ${curdate}\_nmap_scan --reason > /dev/null 2>&1


## now loop through the ports, checking the nmap output and run the nikto scan
echo -e "${INFO} setting up web app scans using ${COL_GREEN}Nikto${COL_NC}"


## take the file targets.lst as input for the initial nmap scan
##  by default, nmap scans the top 1,000 ports including the most common alternate web ports (8080, 8443, etc)
echo -e "${INFO} executing nmap scan on host(s)"
nmap -T3 -n -Pn -iL ${massUniqueList} -oA ${curdate}\_nmap_scan --reason


## now loop through the ports, checking the nmap output and run the nikto scan
for testport in ${ports}
   do for targetip in $(awk '/'${testport}'\/open/ {print $2}' ${curdate}\_nmap_scan.gnmap)
      ## don't prompt for any response; save requests/responses in a dynamic folder; and tune to only look for specific
      ##  data, don't perform a full category scan; provide a valid, generic user agent; format output to HTML and save
      ##  in format YYYY-DD-MM_nikto_IP_PORT.html
			echo -e "${INFO} nikto output to YYYY-DD-MM_nikto_IP_PORT.html based on detected nmap scan(s)"
      do nikto -host ${targetip} -port ${testport} -ask no -nointeractive -nolookup -Save . -Tuning 23489b -useragent "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1" -Format htm -output ${curdate}\_nikto_$targetip\_${testport}.html
   done
done
