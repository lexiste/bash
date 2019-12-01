#!/usr/bin/env bash

##########################################################################
# Copyright:
#  - tips taken from bash3boilerplate.sh as reference and style
##########################################################################

##########################################################################
# Program: <APPLICATION DESCRIPTION HERE>
##########################################################################
VERSION="0.0.1"; # <release>.<major change>.<minor change>
PROGNAME="<APPLICATION NAME>";
AUTHOR="todd fencl";
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

##########################################################################
## Pipeline:
## TODO:
##########################################################################

##########################################################################
# XXX: Coloured variables
#  https://misc.flogisoft.com/bash/tip_colors_and_formatting
#  fg, bg and format can be chained together like
#  ${bold}${uline}${red}My Name is${normal}${yellow}${blink}Fred${normal}
##########################################################################
## foreground colors
red=`echo -e "\033[31m"`
green=`echo -e "\033[32m"`
yellow=`echo -e "\033[33m"`
blue=`echo -e "\033[34m"`
purple=`echo -e "\033[35m"`
lt_red=`echo -e "\033[91m"`
lt_green=`echo -e "\033[92m"`

## background colors .. don't need many
bg_normal=`echo -e "\033[49m"`
bg_red=`echo -e "\033[41m"`
bg_green=`echo -e "\033[42m"`

## text setting
normal=`echo -e "\033[0m"`
bold=`echo -e "\033[1m"`
uline=`echo -e "\033[4m"`
blink=`echo -e "\033[5m"`
hide=`echo -e "\033[8m"`
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

DEBUG=0
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
  echo "${green}${PROGNAME}${normal} ${yellow}version: ${VERSION}${normal} (${AUTHOR})";
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
}

header
main "$@"

debug $param;
