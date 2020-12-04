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

		echo 'calling nmap with opts: ' ${NMAP_OPTIONS} ' using ' ${netblock}

		# since we are passing in the netblock, with a CIDR notation, need to find and remove the /NN
		pos=$netblock | grep -bo "/" | sed 's/:.*$//'
		n=$($netblock | cut --characters=${pos})

		echo 'p: ' $pos ' n: ' $n


		exit 1

		nmap ${NMAP_OPTIONS} ${netblock} -oX ${netblock}_${DATE}.xml > /dev/null
		
		if [ -e ${netblock}-prev.xml ]; then # if there is a -prev file, compare the current run and previous run
			ndiff ${netblock}-prev.xml ${netblock}_${DATE}.xml --text > ${netblock}-diff
			# may want to add a grep filter to the above line ... egrep -v '^(\+|-)N'

			# if the sizeOf(diff_file) > 0
			if [ -s ${netblock}-diff ]; then
				echo '*** NDIFF Detected differences in recent scan ***'
				echo ${netblock}-diff
				echo ''
				echo 'posting to initialstate'
				curl 'https://groker.initialstate.com/api/events?accessKey=wreiLDwxlxP8f1ANx0JRoDE6qBzjWQO5&bucketKey=X4NMERU6AHF8&${netblock}=Changed'
				# TODO >> send email or other notification on the actual change (contents of ${netblock}-diff)
				# update the -prev file since there are changes
				ln -sf ${netblock}_${DATE}.xml ${netblock}-prev.xml
			else
				echo '*** NDIFF found no differences in scans'
				rm ${netblock}_${DATE}.xml
			fi
		else # no -prev file found, so create an initial -prev linked to itself for now
			ln -sf ${netblock}_${DATE}.xml ${netblock}-prev.xml
		fi
		echo 'completed scan of ' ${netblock}

	done < "$NETFILE"
fi

END_TIME=$(date +%s)
echo ''
echo $(date) "- finished all targets in " $(expr ${END_TIME} - ${START_TIME}) " seconds"
