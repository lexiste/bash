#!/usr/bin/env bash

# quick random word generator script

if [ $# -ne 1 ]
  then
    echo "Please specify how many random words would you like to generate !" 1>&2
    echo "example: $0 3" 1>&2
    echo "This will generate 3 random words" 1>&2
    exit 0
fi

# Constants
X=0
_WORDS=/usr/share/dict/words

# total number of words available
_cntWords=`cat $_WORDS | wc -l`

# while loop to generate random words
# number of random generated words depends on supplied argument
#  string the words into a single line as I typically use this to generate filler for emails
while [ "$X" -lt "$1" ] ; do
  random_number=`od -N3 -An -i /dev/urandom | awk -v f=0 -v r="$_cntWords" '{printf "%i ", f + r * $1 / 16777216}'`
#  sed `echo $random_number`"q;d" $_WORDS
  sed `echo $random_number`"q;d" $_WORDS | tr '\n' ' '
  let "X = X + 1"
done

# just a final new-line to make it copy/paste friendly
echo ""
