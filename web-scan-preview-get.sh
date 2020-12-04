#!/bin/bash

# 18March2017 - Based on article from: https://www.trustwave.com/Resources/SpiderLabs-Blog/Using-Nmap-to-Screenshot-Web-Services/fs
printf "<HTML><BODY>\n<BR>" > preview.html

# working output with the IP_ADDR:PORT displayed as the link
#ls -1 *.png | awk -F : '{ printf "<A HREF=\"";sub(/\.png/,"");if ($2 == "443") printf "https://" $1 ; else printf "http://" $1 ; printf ":"$2"\" TARGET=\"_nmapWIN\">" $1":"$2 "</a> <BR> \n" }' >> preview.html

# output with the thumbnail image of the page as the link
ls -1 *.png | awk -F : '{ printf "<A HREF=\"";sub(/\.png/,"");if ($2 == "443") printf "https://" $1 ; else printf "http://" $1 ; printf ":"$2"\" TARGET=\"_nmapWIN\"> <IMG SRC=\""$1"_"$2 ".png\" ALT=\"" $1"_"$2 "\" WIDTH=\"400\"></A> <BR> \n" }' >> preview.html

# original line seems to have problems ...
#ls -1 *.png | awk -F : '{ printf "<A HREF=\"";sub(/\.png/,"");if ($2 == "443") printf "https://" $1 ; else printf "http://" $1 ":" $2 printf "\" TARGET=\"nmapWIN\">" $1 ":" $2 "</A><BR><IMG SRC=\"" $1":" $2 ".png\" WIDTH=400> <BR>\n"}' >> preview.html

printf "</BODY></HTML>" >> preview.html
