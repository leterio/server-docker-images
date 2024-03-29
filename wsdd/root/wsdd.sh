#!/usr/bin/env bash
#===============================================================================
#          FILE: wsdd.sh
#
#         USAGE: ./wsdd.sh
#
#   DESCRIPTION: Entrypoint for wsdd docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Vinícius Letério (viniciusleterio@gmail.com)
#  ORGANIZATION:
#       CREATED: 07/04/2021 (dd/MM/yyyy)
#      REVISION: 1.0
#===============================================================================

set -o nounset

### log: Log any message to output
# Arguments:
#   message) to log
# Return: Formatted message on output
log() {
    local message="${1:-""}"
    [[ $message ]] && echo -e "${0##*/}: $message"
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() {
    local RC="${1:-0}"
    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
ENV             OPTION  DESCRIPTION
                -h      This help
WSDD_DOMAIN     -d \"<domain>\"
                        Set domain name (disables workgroup)
WSDD_HOSTNAME   -n \"<hostname>\"
                        Override (NetBIOS) hostname to be used (default hostname)
WSDD_WORKGROUP  -w \"<workgroup>\"
                        Set workgroup name (default WORKGROUP)
WSDD_IFACE      -i \"<interface>\"
                        Set the network interface for WSDD
" >&2
    exit $RC
}

wsdd_domain=${WSDD_DOMAIN:-""}
wsdd_hostname=${WSDD_HOSTNAME:-""}
wsdd_workgroup=${WSDD_WORKGROUP:-""}
wsdd_iface=${WSDD_IFACE:-""}

while getopts ":hd:n:w:i:" opt; do
    case "$opt" in
        h) usage ;;
        d) wsdd_domain="${OPTARG}" ;;
        n) wsdd_hostname="${OPTARG}" ;;
        w) wsdd_workgroup="${OPTARG}" ;;
        i) wsdd_iface="${OPTARG}" ;;
        "?") log "Unknown option: -$OPTARG"; usage 1 ;;
        ":") log "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

if ps | grep [p]ython | grep -q wsdd.py; then
    log "Service already running, please restart container to apply changes"
else
    log "Launching WSDD${wsdd_hostname:+\n\tHostname: "$wsdd_hostname"}${wsdd_domain:+\n\tDomain: "$wsdd_domain"}${wsdd_workgroup:+\n\tWorkgroup: "$wsdd_workgroup"}${wsdd_iface:+\n\tInterface: "$wsdd_iface"}"

    exec python /wsdd.py \
         ${wsdd_domain:+-d "$wsdd_domain"} \
         ${wsdd_hostname:+-n "$wsdd_hostname"} \
         ${wsdd_workgroup:+-w "$wsdd_workgroup"} \
         ${wsdd_iface:+-i "$wsdd_iface"}
fi
