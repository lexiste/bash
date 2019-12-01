#/bin/bash

# take a single input and perform some whois checks on some TLDs

# check user supplied input
if [ -z "$1" ]
then
   echo "No argument supplied"
   exit 0
fi

# list of TLD's to check -- google top TLD's
declare -a TLD=("com" "net" "biz" "us" "org" "mobi" "uk" "info")
# grab "root" domain from user
domain="$1"

echo
for i in "${TLD[@]}"
do
   echo Checking WHOIS for ["$domain"."$i"]
   whois "$domain"."$i" | grep "Name Server"
done

