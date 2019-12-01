#!/usr/bin/env bash
myPATH="/root/logs/nmap_diff"
myDATE="$(date +%F)"
myTARGETS="10.0.0.160"
myOPTS="-v -T4 -sV -oX scan-$myDATE.xml"

## check if output directory exists ...
if [[ ! -d $myPATH ]]; then
  mkdir -p "$myPATH"
fi

## now move in and get to work
cd "$myPATH"
nmap $myOPTS $myTARGETS > /dev/null
if [[ -f scan-prev.xml ]]; then
  ndiff scan-prev.xml scan-$myDATE.xml >> diff-$myDATE
  echo "***** NDIFF RESULTS *****"
  cat diff-$myDATE
  echo
fi
echo "*** NDIFF RESULTS ***"
cat scan-$myDATE.nmap
ln -s scan-$myDATE.xml scan-prev.xml
