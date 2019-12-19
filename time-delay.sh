#!/usr/bin/env bash

VERSION="0.0.1"
AUTHOR="todd fencl"

declare -A EXIT_CODES
EXIT_CODES['unknown']=-1
EXIT_CODES['ok']=0
EXIT_CODES['generic']=1
EXIT_CODES['limit']=3
EXIT_CODES['missing']=5
EXIT_CODES['failure']=10

DEBUG=0

show_usage() {
  local
  echo -e """little timer script just to show unique way to handle time checks\n
  Usage: $0
  \t-v show version
  \t-h shows the help menu"""
  exit ${EXIT_CODES['ok']}
}

show_version() {
  echo "version: ${VERSION} (${AUTHOR})";
  exit ${EXIT_CODES['ok']}
}

debug() {
  if [[ ${DEBUG} == 1 ]]; then
    echo $1
  fi
}

###############################################################################
## main
###############################################################################
#if [ $# == 0 ] ; then
#  show_usage;
#fi

while getopts :vh opt
do
  case $opt in
    h) show_usage;;
    v) show_version;;
  esac
done

header() {
  clear
  echo -e """
  -------------------------
  v${VERSION} ${AUTHOR}
  -------------------------\n"""
}

main() {
  set -o errexit # exit when command fails
  set -o nounset # exit when script uses undeclared variables

  test_host() {
    ping -q -c 1 "${1:?No target specified}" > /dev/null 2>&1
  }

  ## threshold in number of secords
  threshold=300 # 5 minutes

  ## host to checks
  remote_target_01="8.8.8.8"
  remote_target_02="9.9.9.9"

  ## set default state
  remote_state_01=offline
  remote_state_02=offline

  ## placeholder file for time diferences
  epoch_file_01="/tmp/last_up_${remote_target_01}"
  epoch_file_02="/tmp/last_up_${remote_target_02}"

  ## current epoch
  c_epoch=$(/bin/date +%s)

  ## check health and update status flag
  test_host "${remote_target_01}" && remote_state_01=online
  test_host "${remote_target_02}" && remote_state_02=online

  ## if the status returned up, write the epoch seconds to our file
  [ "${remote_state_01}" = "online" ] && date +%s > "${epoch_file_01}"
  [ "${remote_state_02}" = "online" ] && date +%s > "${epoch_file_02}"

  ## if both are online then do nothing
  if [ "${remote_state_01}" = "online" ] && [ "${remote_state_02}" = "online" ]; then
    echo """hosts 01 & 02 are online and responding to ping check\n"""
    exit ${EXIT_CODES['ok']}
  fi

  if [ "${remote_state_01}" = "offline" ] && [ "${remote_state_02}" = "online" ]; then
    remote_epoch=$(cat "${epoch_file_01}")
    epoch_delta=$(( c_epoch - remote_epoch ))g
    if [ "${epoch_delta}" -ge "${threshold}" ]; then
      echo -e "remote host 1 is down ("${remote_target_01}")\n"
    fi
  fi

  if [ "${remote_state_01}" = "online" ] && [ "${remote_state_02}" = "offline" ]; then
    remote_epoch=$(cat "${epoch_file_02}")
    epoch_delta=$(( c_epoch - remote_epoch ))
    if [ "${epoch_delta}" -ge "${threshold}" ]; then
      echo -e "remote host 2 is down ("${remote_target_02}")\n"
      sleep 30
    fi
  fi

}

header
main "$0"
