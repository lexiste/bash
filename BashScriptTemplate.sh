#!/usr/bin/env bash

##########################################################################
# Copyright:
#  - tips taken from bash3boilerplate.sh as reference and style
##########################################################################

##########################################################################
# Program: <APPLICATION DESCRIPTION HERE>
##########################################################################
readonly VERSION="0.0.1"; # <release>.<major change>.<minor change>
readonly PROGNAME="<APPLICATION NAME>";
readonly AUTHOR="todd fencl";
readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __base="$(basename ${__file} .sh)"
readonly __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

##########################################################################
## Pipeline:
## TODO:
##########################################################################

##########################################################################
# XXX: Coloured variables
##########################################################################
coltable="/home/todd/scripts/bash/COL_TABLE"
if [[ -f ${coltable} ]]; then
  source ${coltable}
fi

##########################################################################
# XXX: Configuration
##########################################################################

declare -A EXIT_CODES
EXIT_CODES['unknown']=-1
EXIT_CODES['ok']=0
EXIT_CODES['generic']=1
EXIT_CODES['limit']=3
EXIT_CODES['missing']=5
EXIT_CODES['failure']=10

local DEBUG=0
param=""

##########################################################################
# XXX: Help Functions
##########################################################################
show_usage() {
  local
  echo -e """Web Application scanner using an array of different pre-made tools\n
  Usage: $0 <target>
  \t-h  shows this help menu
  \t-v  shows the version number and other misc info
  \t-D  displays more verbose output for debugging purposes"""

  exit 1
  exit ${EXIT_CODES['ok']};
}

show_version() {
  echo "${COL_GREEN}${PROGNAME}${COL_NC} ${COL_YELLOW}version: ${VERSION}${COL_NC} (${AUTHOR})";
  exit ${EXIT_CODES['ok']};
}

debug() {
  # Only print when in DEBUG mode
  if [[ ${DEBUG} == 1 ]]; then
    echo $1;
  fi
}

err() {
  echo "$@" 1>&2;
  exit ${EXIT_CODES['generic']};
}

##########################################################################
# XXX: Initialisation and menu
##########################################################################
if [ $# == 0 ] ; then
  show_usage;
fi

while getopts :vhx opt
do
  case $opt in
  v) show_version;;
  h) show_usage;;
  x) _tmp=$OPTARG;;
  *)  echo "Unknown Option: -$OPTARG" >&2; exit 1;;
  esac
done



# Make sure we have all the parameters we need (if you need to force any parameters)
#if [[ -z "$param" ]]; then
#        err "This is a required parameter";
#fi

##########################################################################
# XXX: Kick off
##########################################################################
header() {
        clear
        echo -e """
----------------------------------
 ${PROGNAME} v${VERSION} ${AUTHOR}
----------------------------------\n"""
}

main() {
  set -o errexit  # exit when a command fails
  set -o nounset  # exit when script uses undeclared variables

#start coding here
  echo "start coding here"
  echo "value of -x is $2"

  echo -e "${DONE}"
}

header
main "$@"

debug $param;
