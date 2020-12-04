#!/bin/bash
#
#
# nmap Monitor Script -- used to run a standard scan on given networks that we 
#  can diff against to track for any changes.
# Create Date : 27-Sept-2017
# Mod Date    : 27-Sept-2017
# Mod Auth    : tfencl (at) radial.com
#
# taken as reference from: https://jerrygamblin.com/

# don't wrap the path to the input file as the variable appears to contain either \" or \' as literal
NETFILE=~/scan/radial-ext-net.lst

# use NORMAL scan timing (-T3); TCP Connect (SYN/ACK/FIN); list open ports
NMAP_OPTIONS='-T3 -sT --open'

# store output here ...
cd ~/scan

START_TIME=$(date +%s)

if [[ -r ${NETFILE} ]]; then
	while IFS= read -r netblock; do
		DATE=`date +%d-%b-%Y_%H-%M`

		TARGETS=$(for t in ${netblock}; do prips $t; done)
		for TARGET in ${TARGETS}; do
			cLOG=scan-${TARGET/\//-}-${DATE}
			pLOG=scan-${TARGET/\//-}-prev
			dLOG=scan-${TARGET/\//-}-diff

			#echo $(date +%F-%T) "- starting on ${TARGET}"

			# actual scan starts here
			nmap ${NMAP_OPTIONS} ${TARGET} -oX ${cLOG} >/dev/null

			# if there is a previous log, run diff() on it
			if [ -e ${pLOG} ]; then
				#ndiff ${pLOG} ${cLOG} --text| egrep -v '^(\+|-)N' > ${dLOG}
				ndiff ${pLOG} ${cLOG} --text > ${dLOG}

				# diff filesize >0 bytes, send some notification to someone ... email? Intial State ???
				if [ -s ${dLOG} }]; then
					printf "Changed detected.  Need to send notifications!"
					nmap -sV ${TARGET} | grep open | grep -v "#" > openreport_`date +%h%m%s`.txt
					# set the current log file to the last date changed
					#curl 'https://groker.initialstate.com/api/events?accessKey=wreiLDwxlxP8f1ANx0JRoDE6qBzjWQO5&bucketKey=X4NMERU6AHF8&'${TARGET}'=Changed-'${DATE}
					curl --include \
				    	--request POST \
				    	--header "Content-Type: application/json" \
				    	--header "X-IS-AccessKey: wreiLDwxlxP8f1ANx0JRoDE6qBzjWQO5" \
				    	--header "X-IS-BucketKey: X4NMERU6AHF8" \
				    	--header "Accept-Version: ~0" \
				    	--data-binary "[
				    	{
				    		\"key\": \"${TARGETS}\",
				    		\"value\": \"Changed-${DATE}\"
				    	}
				    	]" \
				    	'https://groker.initialstate.com/api/events'					

					# update the -prev file with the new after the update has been sent
					ln -sf ${cLOG} ${pLOG}
				else
					printf "No changes detected from last scan!"
					rm ${cLOG}
				fi
				#rm ${dLOG}
			else
				# create the previous scan log
				ln -sf ${cLOG} ${pLOG}
			fi
		done
	done < "$NETFILE"
fi

END_TIME=$(date +%s)
echo ''
echo $(date) "- finished all targets in " $(expr ${END_TIME} - ${START_TIME}) " seconds"